select * from flo_data as f limit 4;

--🔹 1. Veri Kontrol & Temizleme
--Tarih formatı kontrolü
--select count(*) from flo_data as f
--🔹 2. Reference Date Belirleme
--RFM için analiz tarihi belirlenir.
select MAX(f.last_order_date) as son_alisveris_tarihi from flo_data as f 
--2021-05-30
--🔹 3. RFM Metriklerini Hesaplama
--Recency
select MAX(f.last_order_date) as son_alıverıs from flo_data as f
--2021-05-30
--Frequency
select COUNT(f.order_num_total_ever_online) as online_siparis_sayısı,COUNT(f.order_num_total_ever_online) as offline_siparis_sayısı from flo_data as f
where f.order_num_total_ever_online is not null or 
f.order_num_total_ever_online is not null;


with cte_1 as(
SELECT
    f.master_id,
    CURRENT_DATE - f.last_order_date as recency,f.order_num_total_ever_offline + f.order_num_total_ever_online as frequency,
    f.customer_value_total_ever_offline + f.customer_value_total_ever_online as monetary
FROM flo_data AS f
),
 cte_2 as (
select 
	*, 
	case 
		when c.recency <= 30 then 5
		when c.recency <=60 then 4
		when c.recency <=90 then 3
		when c.recency <=100 then 2
		when c.recency <=180 then 1
	else 1
	end as recency_score,
	case
		when c.frequency >=20 then 5
		when c.frequency >=10 then 4
		when c.frequency >=5 then 3
		when c.frequency >=2 then 2
	else 1 
	end as frequency_score,
	case
		when c.monetary >=5000 then 5
		when c.monetary >=3000 then 4
		when c.monetary >=1500 then 3
		when c.monetary >=500 then 2
	else 1
	end as monetary_score
from cte_1 as c
),cte_3 as(
	select k.master_id,CONCAT(k.recency_score,frequency_score,k.monetary_score) as rfm_scores from cte_2 as k 
), cte_4 as (		

select *,
		case
			when z.rfm_scores in ('555','554','545') then 'Champion'
			when z.rfm_scores like '55%' then 'Loyal Customer'
			when z.rfm_scores like '1%1' then 'Lost'
		else 'Other'
		end as segments		
from cte_3 as z
)
select * from cte_4








