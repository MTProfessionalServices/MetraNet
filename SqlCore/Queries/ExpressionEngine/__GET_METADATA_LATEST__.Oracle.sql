select * from
(select content from Metadata order by timecreate desc)
where rownum <= 1