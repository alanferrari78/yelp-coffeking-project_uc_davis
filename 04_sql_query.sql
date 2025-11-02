--=====================================================
--Contagem de registros das tabelas
--=====================================================
select 'tb_business' table, count (1) from public.tb_business 
union
select 'tb_checkin' table, count (1) from public.tb_checkin
union
select 'tb_review' table, count (1) from public.tb_review
union
select 'tb_tip' table, count (1) from public.tb_tip
union
select 'tb_user' table, count (1) from public.tb_user;
--=====================================================
--Empresas categoria Café
--===================================================== 
select 
case when categories ilike '%coffee%' or categories ilike 'cafe' then 'caffee' 
else 'outros' end as business_categories,
count(1) count_business
from public.tb_business
group by case when categories ilike '%coffee%' or categories ilike 'cafe' then 'caffee' 
else 'outros' end;
--=====================================================
--Review de empresas categoria Café
--=====================================================  
select case 
	when b.categories ilike '%coffee%' or b.categories ilike 'cafe' then 'caffee' 
	else 'outros' end as business_categories,
count(1) as count_review
from public.tb_review a
inner join public.tb_business b on a.business_id = b.business_id 
group by case when b.categories ilike '%coffee%' or b.categories ilike 'cafe' then 'caffee' 
	else 'outros' end;
--=====================================================
--Adequação de índices
--=====================================================  
-- existentes
CREATE UNIQUE IF NOT INDEX tb_business_pkey ON public.tb_business USING btree (business_id)
CREATE UNIQUE IF NOT INDEX tb_review_pkey ON public.tb_review USING btree (review_id)
CREATE UNIQUE IF NOT INDEX tb_tip_pkey ON public.tb_tip USING btree (tip_id)
CREATE UNIQUE IF NOT INDEX tb_user_pkey ON public.tb_user USING btree (user_id)
--novos
CREATE INDEX IF NOT EXISTS idx_review_business_id ON tb_review (business_id);
CREATE INDEX IF NOT EXISTS idx_review_user_id ON tb_review (user_id);
CREATE INDEX IF NOT EXISTS idx_tip_business_id ON tb_tip (business_id);
CREATE INDEX IF NOT EXISTS idx_tip_user_id ON tb_tip (user_id);
--Índice para o filtro de Categoria (acelera o ILIKE)
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX IF NOT EXISTS idx_business_categories_gin ON tb_business USING GIN (categories gin_trgm_ops);
--Índice para o filtro de Estrelas (Hipótese 1)
CREATE INDEX IF NOT EXISTS idx_review_stars ON tb_review (stars);
--=====================================================
--Consulta de Estatísticas Descritivas
--=====================================================
WITH base AS (SELECT b.stars AS business_stars, 
b.review_count AS business_review_count,r.stars AS review_stars,u.fans
		from tb_business AS b
		LEFT JOIN tb_review AS r ON b.business_id = r.business_id
		LEFT JOIN tb_user AS u ON u.user_id = r.user_id
		WHERE b.categories ILIKE '%Coffee%' OR b.categories ILIKE '%Cafes%')
SELECT
    '1. Review Scores (review_stars)' AS metric,
    COUNT(review_stars) AS total_count,
    AVG(review_stars) AS average,
    percentile_cont(0.5) WITHIN GROUP (ORDER BY review_stars) AS median,
    mode() WITHIN GROUP (ORDER BY review_stars) AS mode,
    MIN(review_stars) AS minimum,
    MAX(review_stars) AS maximum,
    percentile_cont(0.25) WITHIN GROUP (ORDER BY review_stars) AS quartile_25,
    percentile_cont(0.75) WITHIN GROUP (ORDER BY review_stars) AS quartile_75
FROM base
UNION ALL
SELECT
    '2. Business Popularity (business_review_count)' AS metric,
    COUNT(DISTINCT business_review_count) AS total_count, -- Nota: Contagem de lojas
    AVG(business_review_count) AS average,
    percentile_cont(0.5) WITHIN GROUP (ORDER BY business_review_count) AS median,
    mode() WITHIN GROUP (ORDER BY business_review_count) AS mode,
    MIN(business_review_count) AS minimum,
    MAX(business_review_count) AS maximum,
    percentile_cont(0.25) WITHIN GROUP (ORDER BY business_review_count) AS quartile_25,
    percentile_cont(0.75) WITHIN GROUP (ORDER BY business_review_count) AS quartile_75
FROM base
WHERE business_review_count IS NOT NULL
UNION ALL
SELECT
    '3. User Popularity (user_fans)' AS metric,
    COUNT(fans) AS total_count,
    AVG(fans) AS average,
    percentile_cont(0.5) WITHIN GROUP (ORDER BY fans) AS median,
    mode() WITHIN GROUP (ORDER BY fans) AS mode,
    MIN(fans) AS minimum,
    MAX(fans) AS maximum,
    percentile_cont(0.25) WITHIN GROUP (ORDER BY fans) AS quartile_25,
    percentile_cont(0.75) WITHIN GROUP (ORDER BY fans) AS quartile_75
FROM base
WHERE fans IS NOT NULL;
--=====================================================
--Hipótese 1: Sentimento (Atendimento/Ambiente vs. Preço)
--=====================================================
SELECT 
    r.stars,
    COUNT(*) AS total_reviews,
    (COUNT(CASE WHEN r.text ILIKE '%service%' OR r.text ILIKE '%staff%' OR r.text ILIKE '%friendly%' OR r.text ILIKE '%rude%' THEN 1 END) * 100.0 / COUNT(*)) AS pct_mentions_service,
    (COUNT(CASE WHEN r.text ILIKE '%atmosphere%' OR r.text ILIKE '%ambiance%' OR r.text ILIKE '%vibe%' THEN 1 END) * 100.0 / COUNT(*)) AS pct_mentions_atmosphere,
    (COUNT(CASE WHEN r.text ILIKE '%flavor%' OR r.text ILIKE '%taste%' THEN 1 END) * 100.0 / COUNT(*)) AS pct_mentions_flavor,
    (COUNT(CASE WHEN r.text ILIKE '%price%' OR r.text ILIKE '%expensive%' OR r.text ILIKE '%cheap%' THEN 1 END) * 100.0 / COUNT(*)) AS pct_mentions_price
FROM  tb_review AS r
JOIN tb_business AS b ON r.business_id = b.business_id
where (b.categories ILIKE '%Coffee%' OR b.categories ILIKE '%Cafes%') AND (r.stars = 1 OR r.stars = 5) 
GROUP BY r.stars
ORDER BY r.stars;
--=====================================================
--Hipótese 2: Wi-Fi vs. Volume de Reviews
--=====================================================
SELECT 
    replace(replace(attributes->>'WiFi','u',''),'''','') AS wifi_status, 
    COUNT(business_id) AS total_de_cafeterias,
    round(AVG(review_count),2) AS media_de_reviews,
    round(AVG(stars)::decimal,2) AS media_de_estrelas
FROM tb_business
where (categories ILIKE '%Coffee%' OR categories ILIKE '%Cafes%') AND attributes->>'WiFi' IS NOT NULL 
GROUP BY wifi_status
ORDER BY media_de_reviews DESC;
--=====================================================
--Hipótese 3: Usuários "Elite"
--=====================================================
SELECT 
    CASE WHEN u.elite IS NOT NULL AND u.elite != '' THEN 'Elite' ELSE 'Non-Elite' END AS user_type,
    COUNT(r.review_id) AS total_reviews,
    round(AVG(r.stars)::decimal,2) AS average_stars,
    round((COUNT(CASE WHEN r.text ILIKE '%flavor%' OR r.text ILIKE '%taste%' THEN 1 END) * 100.0 / COUNT(r.review_id)),2) AS pct_mentions_flavor,
    round((COUNT(CASE WHEN r.text ILIKE '%price%' OR r.text ILIKE '%expensive%' THEN 1 END) * 100.0 / COUNT(r.review_id)),2) AS pct_mentions_price
FROM tb_review AS r
JOIN tb_business AS b ON r.business_id = b.business_id
JOIN tb_user AS u ON r.user_id = u.user_id
where (b.categories ILIKE '%Coffee%' OR b.categories ILIKE '%Cafes%') -- Filtro para Cafeterias
GROUP BY user_type;
--=====================================================
--Relacionamentos e correlação, correlação de Pearson 
--=====================================================
select corr(stars, review_count) AS correlation_rating_vs_volume
from tb_business
where (categories ILIKE '%Coffee%' OR categories ILIKE '%Cafes%');