--=====================================================
--database
--=====================================================
CREATE DATABASE yelp_db;
--=====================================================
--Tabela user
--=====================================================
create table if not exists public.tb_user (		
	user_id 			VARCHAR(255) PRIMARY KEY,
	name 				TEXT,
	review_count 		INTEGER,
	yelping_since 		TIMESTAMP,
	useful 				INTEGER,
	funny				INTEGER,
	cool 				INTEGER,
	elite 				TEXT,
	friends 			TEXT,
	fans 				INTEGER,
	average_stars 		FLOAT,
	compliment_hot 		INTEGER,
	compliment_more 	INTEGER,
	compliment_profile 	INTEGER,
	compliment_cute 	INTEGER,
	compliment_list 	INTEGER,
	compliment_note 	INTEGER,
	compliment_plain 	INTEGER,
	compliment_cool 	INTEGER,
	compliment_funny 	INTEGER,
	compliment_writer 	INTEGER,
	compliment_photos 	INTEGER);
--Comentário da Tabela 
COMMENT ON TABLE public.tb_user IS 'Tabela de usuários. Contém dados demográficos e de perfil de cada usuário. Criada por Alan Ferrari em 21/10/2025.';
--Comentários das Colunas
COMMENT ON COLUMN public.tb_user.user_id IS 'ID único do usuário. Chave Primária (PK) da tabela tb_user.';
COMMENT ON COLUMN public.tb_user.name IS 'Primeiro nome do usuário (pode ser nulo ou não confiável).';
COMMENT ON COLUMN public.tb_user.review_count IS 'Número total de reviews (avaliações) escritas por este usuário.';
COMMENT ON COLUMN public.tb_user.yelping_since IS 'Data e hora de quando o usuário se cadastrou no Yelp.';
COMMENT ON COLUMN public.tb_user.useful IS 'Número total de votos "Útil" recebidos pelos reviews deste usuário.';
COMMENT ON COLUMN public.tb_user.funny IS 'Número total de votos "Engraçado" recebidos pelos reviews deste usuário.';
COMMENT ON COLUMN public.tb_user.cool IS 'Número total de votos "Legal" recebidos pelos reviews deste usuário.';
COMMENT ON COLUMN public.tb_user.elite IS 'String com os anos em que o usuário foi "Elite", separados por vírgula (ex: "2017,2018").';
COMMENT ON COLUMN public.tb_user.friends IS 'String longa contendo uma lista de user_ids de amigos. Requer tratamento (parsing).';
COMMENT ON COLUMN public.tb_user.fans IS 'Número de usuár que seguem este usuário (fãs).';
COMMENT ON COLUMN public.tb_user.average_stars IS 'Média de estrelas dadas por este usuário em todos os seus reviews.';
COMMENT ON COLUMN public.tb_user.compliment_hot IS 'Contagem de elogios do tipo "Hot" recebidos.';
COMMENT ON COLUMN public.tb_user.compliment_more IS 'Contagem de elogios do tipo "More" recebidos.';
COMMENT ON COLUMN public.tb_user.compliment_profile IS 'Contagem de elogios do tipo "Profile" recebidos.';
COMMENT ON COLUMN public.tb_user.compliment_cute IS 'Contagem de elogios do tipo "Cute" recebidos.';
COMMENT ON COLUMN public.tb_user.compliment_list IS 'Contagem de elogios do tipo "List" recebidos.';
COMMENT ON COLUMN public.tb_user.compliment_note IS 'Contagem de elogios do tipo "Note" recebidos.';
COMMENT ON COLUMN public.tb_user.compliment_plain IS 'Contagem de elogios do tipo "Plain" recebidos.';
COMMENT ON COLUMN public.tb_user.compliment_cool IS 'Contagem de elogios do tipo "Cool" recebidos.';
COMMENT ON COLUMN public.tb_user.compliment_funny IS 'Contagem de elogios do tipo "Funny" recebidos.';
COMMENT ON COLUMN public.tb_user.compliment_writer IS 'Contagem de elogios do tipo "Writer" recebidos.';
COMMENT ON COLUMN public.tb_user.compliment_photos IS 'Contagem de elogios do tipo "Photos" recebidos.';
--=====================================================
--Tabela business
--=====================================================
create table if not exists public.tb_business (	
	business_id 		VARCHAR(255) PRIMARY KEY,
	name 				TEXT,
	address 			TEXT,
	city				VARCHAR(255),
	state 				VARCHAR(5),
	postal_code 		VARCHAR(20),
	latitude 			FLOAT,
	longitude 			FLOAT,
	stars 				FLOAT,
	review_count 		INTEGER,
	is_open 			INTEGER,
	attributes 			JSONB,
	categories 			TEXT,
	hours 				JSONB);
--Comentário da Tabela 
COMMENT ON TABLE public.tb_business IS 'Tabela de negócios (restaurantes, lojas, etc.). Contém dados de localização, atributos e categorias. Criada por Alan Ferrari em 21/10/2025.';
--Comentários das Colunas
COMMENT ON COLUMN public.tb_business.business_id IS 'ID único do negócio. Chave Primária (PK) da tabela tb_business.';
COMMENT ON COLUMN public.tb_business.name IS 'Nome oficial do negócio.';
COMMENT ON COLUMN public.tb_business.address IS 'Endereço completo do negócio.';
COMMENT ON COLUMN public.tb_business.city IS 'Cidade onde o negócio está localizado.';
COMMENT ON COLUMN public.tb_business.state IS 'Sigla do estado (ex: "PA", "CA").';
COMMENT ON COLUMN public.tb_business.postal_code IS 'Código postal (CEP) do negócio.';
COMMENT ON COLUMN public.tb_business.latitude IS 'Coordenada geográfica de latitude.';
COMMENT ON COLUMN public.tb_business.longitude IS 'Coordenada geográfica de longitude.';
COMMENT ON COLUMN public.tb_business.stars IS 'Média de estrelas (avaliação) do negócio, de 1 a 5.';
COMMENT ON COLUMN public.tb_business.review_count IS 'Número total de reviews recebidos por este negócio.';
COMMENT ON COLUMN public.tb_business.is_open IS 'Indicador se o negócio está aberto (1) ou fechado (0).';
COMMENT ON COLUMN public.tb_business.attributes IS 'Campo JSONB contendo diversos atributos (ex: "BusinessAcceptsCreditCards", "BusinessParking").';
COMMENT ON COLUMN public.tb_business.categories IS 'String com a lista de categorias do negócio, separadas por vírgula.';
COMMENT ON COLUMN public.tb_business.hours IS 'Campo JSONB contendo os horários de funcionamento por dia da semana.';
--=====================================================
--Tabela checkin
--=====================================================
create table if not exists public.tb_checkin (
	business_id 		VARCHAR(255) REFERENCES tb_business(business_id),
	date 				TEXT);
--Comentário da Tabela 
COMMENT ON TABLE public.tb_checkin IS 'Tabela de check-ins. Contém uma string agregada de todas as datas de check-in para um negócio. Criada por Alan Ferrari em 21/10/2025.';
--Comentários das Colunas
COMMENT ON COLUMN public.tb_checkin.business_id IS 'ID do negócio. Chave Estrangeira (FK) conceitual para tb_business.';
COMMENT ON COLUMN public.tb_checkin.date IS 'String de texto longa contendo todas as datas/horas de check-in, separadas por vírgula.';
--=====================================================
--Tabela tip
--=====================================================
create table if not exists public.tb_tip (		
	tip_id 				SERIAL PRIMARY KEY, 
	text 				TEXT,
	date 				TIMESTAMP,
	compliment_count 	INTEGER, 
	user_id 			VARCHAR(255) REFERENCES tb_user(user_id),
	business_id 		VARCHAR(255) REFERENCES tb_business(business_id));

--Comentário da Tabela 
COMMENT ON TABLE public.tb_tip IS 'Tabela de "dicas" (tips). Tabela "fato" que liga usuários e negócios, contendo recomendações curtas. Criada por Alan Ferrari em 21/10/2025.';
--Comentários das Colunas
COMMENT ON COLUMN public.tb_tip.tip_id IS 'ID único da dica (tip). Chave Primária (PK) auto-incremental (SERIAL).';
COMMENT ON COLUMN public.tb_tip.user_id IS 'ID do usuário que escreveu a dica. Chave Estrangeira (FK) conceitual para tb_user.';
COMMENT ON COLUMN public.tb_tip.business_id IS 'ID do negócio que recebeu a dica. Chave Estrangeira (FK) conceitual para tb_business.';
COMMENT ON COLUMN public.tb_tip.text IS 'O texto da dica.';
COMMENT ON COLUMN public.tb_tip.date IS 'Data e hora em que a dica foi escrita.';
COMMENT ON COLUMN public.tb_tip.compliment_count IS 'Número de elogios que esta dica recebeu.';
--=====================================================
--Tabela review
--=====================================================
create table if not exists public.tb_review (	
	review_id 			VARCHAR(255) PRIMARY KEY,
	user_id 			VARCHAR(255),
	business_id 		VARCHAR(255) REFERENCES tb_business(business_id),
	stars 				FLOAT,
	useful 				INTEGER,
	funny 				INTEGER,
	cool 				INTEGER,
	text 				TEXT,
	date 				TIMESTAMP);
--Comentário da Tabela 
COMMENT ON TABLE public.tb_review IS 'Tabela de reviews (avaliações). Tabela "fato" que liga usuários e negócios. Criada por Alan Ferrari em 21/10/2025.';
--Comentários das Colunas
COMMENT ON COLUMN public.tb_review.review_id IS 'ID único do review. Chave Primária (PK) da tabela.';
COMMENT ON COLUMN public.tb_review.user_id IS 'ID do usuário que escreveu o review. Chave Estrangeira (FK) conceitual para tb_user.';
COMMENT ON COLUMN public.tb_review.business_id IS 'ID do negócio que recebeu o review. Chave Estrangeira (FK) conceitual para tb_business.';
COMMENT ON COLUMN public.tb_review.stars IS 'Nota (estrelas) dada no review, de 1 a 5.';
COMMENT ON COLUMN public.tb_review.useful IS 'Número de votos "Útil" que este review recebeu.';
COMMENT ON COLUMN public.tb_review.funny IS 'Número de votos "Engraçado" que este review recebeu.';
COMMENT ON COLUMN public.tb_review.cool IS 'Número de votos "Legal" que este review recebeu.';
COMMENT ON COLUMN public.tb_review.text IS 'O texto completo do review.';
COMMENT ON COLUMN public.tb_review.date IS 'Data e hora em que o review foi escrito.';
--
