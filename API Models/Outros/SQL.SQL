Chamados por fila
 
SQL
SELECT   queue.name, count(tn) as chamados from ticket join queue on queue_id = queue.id and queue.name like concat($Fila,'%') group BY queue_id
order by 1





Chamado por tipo
 
SQL
SELECT tt.name as "Tipo de Chamado", q.name as Fila, count(t.id) as Chamados FROM ticket t 
join ticket_type tt on t.type_id = tt.id
join queue q on t.queue_id = q.id and q.name like concat($Fila,'%')
group by tt.name, q.name
order by Chamados desc






Estado do SLA
 
SQL
select if(s.solution_time*60 > hh.tempo_total,"Prazo Cumprido","Prazo Excedido") as Metrica, count(t.id) as quantidade
FROM
(
    select h.ticket_id, sum(tempo_passado) as tempo_total
      FROM (
        SELECT
            ticket_id,
            id,
            name,
            create_time,
            timestampdiff(second,
                          LAG(create_time,1) OVER( PARTITION BY ticket_id order by ticket_id, id),
                          create_time) as tempo_passado
            FROM
            ticket_history
        where history_type_id = 27 #and create_time BETWEEN '2022-09-01' and '2022-09-30'
    ) h
    group by ticket_id
) hh
join ticket t on
t.id = hh.ticket_id
join sla s on
s.id = t.sla_id
group by Metrica
order by ticket_id





SLA por tecnico
 
SQL
select u.login,
if(s.solution_time*60 > hh.tempo_total,"Prazo Cumprido","Prazo Excedido") as Metrica, count(t.id) as quantidade
FROM
(
    select h.ticket_id, sum(tempo_passado) as tempo_total
      FROM (
        SELECT
            ticket_id,
            id,
            name,
            create_time,
            timestampdiff(second,
                          LAG(create_time,1) OVER( PARTITION BY ticket_id order by ticket_id, id),
                          create_time) as tempo_passado
            FROM
            ticket_history
        where history_type_id = 27 and create_time BETWEEN '2022-09-01' and '2022-09-30'
    ) h
    group by ticket_id
) hh
join ticket t on
t.id = hh.ticket_id
join sla s on
s.id = t.sla_id
join queue q on
t.queue_id = q.id
join users u on
t.user_id = u.id
group by u.login, Metrica 
order by q.name, Metrica





SLA por fila
 
SQL
select q.name as Fila,
if(s.solution_time*60 > hh.tempo_total,"Prazo Cumprido","Prazo Excedido") as Metrica, count(t.id) as quantidade
FROM
(
    select h.ticket_id, sum(tempo_passado) as tempo_total
      FROM (
        SELECT
            ticket_id,
            id,
            name,
            create_time,
            timestampdiff(second,
                          LAG(create_time,1) OVER( PARTITION BY ticket_id order by ticket_id, id),
                          create_time) as tempo_passado
            FROM
            ticket_history
        where history_type_id = 27 and create_time BETWEEN '2022-09-01' and '2022-09-30'
    ) h
    group by ticket_id
) hh
join ticket t on
t.id = hh.ticket_id
join sla s on
s.id = t.sla_id
join queue q on
t.queue_id = q.id
join users u on
t.user_id = u.id
group by q.name, Metrica 
order by q.name, Metrica





Chamados Abertos por celula
 
SQL
SELECT
    count(*) as "Tecnologia"
from
    ticket
WHERE
    queue_id in (5,6,7,8)
    and customer_id = 'Tecnologia'
    and create_time BETWEEN '2022-08-01 00:00:00' and '2022-08-31 23:59:59';




Chamados fechados por celula
 
SQL
SELECT
    count(*) as "Tecnologia"
from
    ticket
WHERE
    queue_id in (5,6,7,8)
    and customer_id = 'Tecnologia'
    and change_time BETWEEN '2022-08-01 00:00:00' and '2022-08-31 23:59:59';





Total de chamados abertos no mes
 
SQL
SELECT
    count(*) as "Total de Chamados"
from
    ticket
WHERE
    queue_id in (5,6,7,8)
    and customer_id in ('DHO','Backoffice','Gestão da Estratégia','Tecnologia','Soluções','Operações','Negócios','Diretoria')
    and create_time BETWEEN '2022-08-01 00:00:00' and '2022-08-31 23:59:59';






Total de chamados fechados do mes
 
SQL
SELECT
    count(*) as "Total de Chamados"
from
    ticket
WHERE
    queue_id in (5,6,7,8)
    and customer_id in ('DHO','Backoffice','Gestão da Estratégia','Tecnologia','Soluções','Operações','Negócios','Diretoria')
    and change_time BETWEEN '2022-08-01 00:00:00' and '2022-08-31 23:59:59';







Chamado fechado por tecnico
 
SQL
SELECT
    count(*) as 'Erlandeson'
from
    ticket
WHERE
    queue_id in (6)
    and ticket_state_id in (2,3,5)
    and user_id = 38
    and change_time BETWEEN '2022-10-01 00:00:00' and CONCAT(CURDATE(),' 23:59:59') ;

