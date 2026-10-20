-- Mesure du poids de l'index par passage (texte intégral + vecteur 1024).
-- 2 000 passages d'environ 800 caractères = 10 pages × 200 documents.
begin;
insert into public.documents (id, school_id, space, title)
values ('5f000000-0000-4000-8000-000000000001', '10000000-0000-4000-8000-000000000001', 'bibliotheque', 'Mesure');
insert into public.document_chunks (school_id, document_id, page, chunk_index, content, embedding)
select '10000000-0000-4000-8000-000000000001', '5f000000-0000-4000-8000-000000000001', g / 2, g,
       repeat('Leçon de calcul sur la multiplication des nombres décimaux, exercice ' || g || '. ', 10),
       (select array_agg(random())::extensions.vector from generate_series(1, 1024))
  from generate_series(1, 2000) g;
create index mesure_hnsw on public.document_chunks using hnsw (embedding extensions.vector_cosine_ops);
select 'octets_par_passage_total' as mesure,
       pg_total_relation_size('public.document_chunks') / 2000 as valeur
union all
select 'octets_par_passage_sans_hnsw',
       (pg_total_relation_size('public.document_chunks') - pg_relation_size('mesure_hnsw')) / 2000;
rollback;
