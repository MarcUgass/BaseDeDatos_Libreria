1. De cada mes (del 1 al 30) es vol saber si la tenda té pèrdues (quan s’ha
facturat i quan s’ha gastat).

select T.mes, sum(T.gastos) as gastos, sum(T.guanys) as guanys,
sum(T.guanys)-sum(T.gastos) as Benefici
from (select to_char(f.data, 'mm/yyyy')as mes, sum(f.preu_total) as gastos, 0 as
guanys
from factura f
where f.distribuidor_nif is not null
group by to_char(f.data, 'mm/yyyy')
union
select
to_char(f.data, 'mm/yyyy') as mes, 0, sum(f.preu_total) as guanys
from factura f
where f.distribuidor_nif is null
group by to_char(f.data, 'mm/yyyy')
union
select to_char(t.data, 'mm/yyyy') as mes, 0, sum(t.preu_total) as guanys
from tiquet t
group by to_char(t.data, 'mm/yyyy')) T
group by T.mes
order by 1


2. Quin és el perfil d’usuari que ve a la tenda de còmics? Gènere de còmics més
venut per sexe, edat o població.
Sexe:
select p.tipus, c.sexe
from factura f, factura_client fc, publicacio p, client c
where fc.client_nif=c.nif and f.numeracio=fc.factura_numeracio and
p.isbn=f.exemplars
group by p.tipus, c.sexe
having sum(f.exemplars)=(select max(sum(f.exemplars))
from factura f, publicacio p, client c, factura_client fc
where fc.client_nif=c.nif and f.numeracio=fc.factura_numeracio and
p.isbn=f.exemplars)
order by 1,2;

Edat:
select p.tipus, c.edat
from publicacio p. client c, factura t, factura_client fc
WHERE fc.publicacio_isbn=p.isbn and fc.factura_numeracio=f.numeracio
group by p.tipus, c.edat
having sum(f.exemplars) = (select max(sum(t.exemplars)
from factura f, publicacio p, client c, factura_client fc
where fc.publicacio_isbn=p.isbn and fc.factura_numeracio=f.numeracio)
order by BY 1, 2;

Població:
select p.tipus, c.poblacio
from publicacio p, client c, factura f, factura_client fc
where fc.publicacio_isbn=p.isbn and fc.factura_numeracio=f.numeracio
group by p.genere, c.poblacio
having sum(f.exemplars) = (select max(sum(t.exemplars)
from factura f, publicacio p, client c, factura_client fc
where fc.publicacio_isbn=p.isbn and fc.factura_numeracio=f.numeracio)
order by 1, 2;


3. Donat el nom d’una publicació, on es troba a la tenda?
select p.titol, u.columna, u.fila, u.estant, u.sala
from ubicacio u, publicacio p
where p.titol = 'Taula Trencada'
and p.ISBN = u.ISBN_publicacio
order by 1,2,3,4


4. Control d’estoc. Saber quines són les estanteries de la tenda que tenen l’estoc
a 0.
(select u.estant
from ubicacio u, publicacio p
where u.isbn_publicacio = p.isbn)
minus
(select u.estant
from ubicacio u, publicacio p
where u.isbn_publicacio = p.isbn
and u.isbn_pulbicacio is not null)
order by 1;


5. Classificació de ventes segons autor, personatge, publicació i premis (4
consultes diferents)
Autor:
select p.autor, sum(v.n_unitats)
from publicacio p, venta v
where p.isbn = v.isbn_publicacio
group by p.autor
order by 1,2;

Personatge:
select p.personatge, sum(v.n_unitats)
from publicacio p, venta v
where p.isbn = v.isbn_publicacio
group by p.personatge
order by 1,2;

Publicació:
select p.titol, sum(v.n_unitats)
from publicacio p, venta v
where p.isbn = v.isbn_publicacio
group by p.titol
order by 1,2;

Premi:
select pr.tipus, sum(v.n_unitats)
from publicacio p, venta v, premi pr
where p.isbn = v.isbn_publicacio
and pr.nom_salo = p.nom_salo_premi
and pr.nom_edicio = p.nom_edicio_premi
group by pr.tipus
order by 1,2;