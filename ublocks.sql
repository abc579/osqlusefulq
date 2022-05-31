/* Check blocks between users. */
SELECT s1.username || '@' || s1.machine || ' ( SID=' || s1.sid || ' SERIAL=' ||
       s1.serial# || ' ) is blocking ' || s2.username || '@' || s2.machine ||
       ' ( SID=' || s2.sid || ' SERIAL=' || s2.serial# || ' ) ' AS blocks
  FROM v$lock    l1
      ,v$session s1
      ,v$lock    l2
      ,v$session s2e
 WHERE s1.sid = l1.sid
   AND s2.sid = l2.sid
   AND l1.block = 1
   AND l2.request > 0
   AND l1.id1 = l2.id1
   AND l2.id2 = l2.id2;
