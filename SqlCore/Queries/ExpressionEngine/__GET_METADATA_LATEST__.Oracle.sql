select * from
(select content from Metadata order by createtime desc)
where rownum <= 1