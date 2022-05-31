/* Get sessions with some stats and also kill commands to execute if needed. */
SELECT s.osuser
      ,s.username
      ,s.machine
      ,s.program
      ,round(p.pga_used_mem / power(1024, 2), 2) AS pga_used_memmb
      ,round(p.pga_alloc_mem / power(1024, 2), 2) AS pga_alloc_memmb
      ,round(p.pga_freeable_mem / power(1024, 2), 2) AS pga_freeable_memmb
      ,round(p.pga_max_mem / power(1024, 2), 2) AS pga_max_memmb
      ,s.action
      ,'ALTER SYSTEM KILL SESSION ''' || sid || ',' || s.serial# || ',@' || s.inst_id || ''' IMMEDIATE;' AS kill_c
      ,s.inst_id
      ,s.sid
      ,s.serial#
      ,p.spid
      ,s.status
      ,'exec system.p_rkillsession(' || s.sid || ',' || s.serial# || ');' AS kill_local
  FROM gv$session s
      ,gv$process p
 WHERE p.addr = s.paddr
   AND p.inst_id = s.inst_id
   AND NVL(s.username, 'SYS') NOT IN ('SYS', 'SYSTEM', 'SYSMAN', 'DBSNMP')
   AND UPPER(s.username) LIKE '%FONDOS%'
   AND s.type != 'BACKGROUND'
ORDER BY 6 DESC
        ,1
        ,2;
