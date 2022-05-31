/* Check if someone is blocking an object. */
SELECT l.sid
      ,s.osuser osuser_locker
      ,s.machine
      ,s.program
      ,o.object_name object_name
      ,o.object_type object_type
      ,DECODE(l.type
             ,'BL'
             ,'Buffer hash table'
             ,'CF'
             ,'Control File Transaction'
             ,'CI'
             ,'Cross Instance Call'
             ,'CS'
             ,'Control File Schema'
             ,'CU'
             ,'Bind Enqueue'
             ,'DF'
             ,'Data File'
             ,'DL'
             ,'Direct-loader index-creation'
             ,'DM'
             ,'Mount/startup db primary/secondary instance'
             ,'DR'
             ,'Distributed Recovery Process'
             ,'DX'
             ,'Distributed Transaction Entry'
             ,'FI'
             ,'SGA Open-File Information'
             ,'FS'
             ,'File Set'
             ,'IN'
             ,'Instance Number'
             ,'IR'
             ,'Instance Recovery Serialization'
             ,'IS'
             ,'Instance State'
             ,'IV'
             ,'Library Cache InValidation'
             ,'JQ'
             ,'Job Queue'
             ,'KK'
             ,'Redo Log "Kick"'
             ,'LS'
             ,'Log Start/Log Switch'
             ,'MB'
             ,'Master Buffer hash table'
             ,'MM'
             ,'Mount Definition'
             ,'MR'
             ,'Media Recovery'
             ,'PF'
             ,'Password File'
             ,'PI'
             ,'Parallel Slaves'
             ,'PR'
             ,'Process Startup'
             ,'PS'
             ,'Parallel Slaves Synchronization'
             ,'RE'
             ,'USE_ROW_ENQUEUE Enforcement'
             ,'RT'
             ,'Redo Thread'
             ,'RW'
             ,'Row Wait'
             ,'SC'
             ,'System Commit Number'
             ,'SH'
             ,'System Commit Number HWM'
             ,'SM'
             ,'SMON'
             ,'SQ'
             ,'Sequence Number'
             ,'SR'
             ,'Synchronized Replication'
             ,'SS'
             ,'Sort Segment'
             ,'ST'
             ,'Space Transaction'
             ,'SV'
             ,'Sequence Number Value'
             ,'TA'
             ,'Transaction Recovery'
             ,'TD'
             ,'DDL enqueue'
             ,'TE'
             ,'Extend-segment enqueue'
             ,'TM'
             ,'DML enqueue'
             ,'TS'
             ,'Temporary Segment'
             ,'TT'
             ,'Temporary Table'
             ,'TX'
             ,'Transaction'
             ,'UL'
             ,'User-defined Lock'
             ,'UN'
             ,'User Name'
             ,'US'
             ,'Undo Segment Serialization'
             ,'WL'
             ,'Being-written redo log instance'
             ,'WS'
             ,'Write-atomic-log-switch global enqueue'
             ,'XA'
             ,'Instance Attribute'
             ,'XI'
             ,'Instance Registration'
             ,DECODE(substr(l.type, 1, 1)
                    ,'L'
                    ,'Library Cache (' || substr(l.type, 2, 1) || ')'
                    ,'N'
                    ,'Library Cache Pin (' || substr(l.type, 2, 1) || ')'
                    ,'Q'
                    ,'Row Cache (' || substr(l.type, 2, 1) || ')'
                    ,'????')) TYPE
      ,l.id1
      ,l.id2
      ,DECODE(l.lmode
             ,0
             ,'None(0)'
             ,1
             ,'Null(1)'
             ,2
             ,'Row Share(2)'
             ,3
             ,'Row Exclu(3)'
             ,4
             ,'Share(4)'
             ,5
             ,'Share Row Ex(5)'
             ,6
             ,'Exclusive(6)') lmode
      ,DECODE(l.request
             ,0
             ,'None(0)'
             ,1
             ,'Null(1)'
             ,2
             ,'Row Share(2)'
             ,3
             ,'Row Exclu(3)'
             ,4
             ,'Share(4)'
             ,5
             ,'Share Row Ex(5)'
             ,6
             ,'Exclusive(6)') request1
      ,l.ctime
      ,l.block
       /*
       ,s.process process_locker
       ,s.username dbuser_locker
       */
      ,s.wait_class
      ,s.event
      ,s.program
  FROM v$lock      l
      ,all_objects o
      ,v$session   s
 WHERE l.sid > 5
      --
      --> Row Locks (TX)
      --  Row-level locks are primarily used to prevent two transactions from modifying the same row.
      --  When a transaction needs to modify a row, a row lock is acquired.
      --
      --> Table Locks (TM)
      --  Table-level locks are primarily used to do concurrency control with concurrent DDL operations,
      --  such as preventing a table from being dropped in the middle of a DML operation
      --
   AND l.type IN ('TM', 'TX')
   AND l.id1 = o.object_id
   AND s.sid = l.sid
 ORDER BY DECODE(l.request, 0, 0, 2)
         ,BLOCK
         ,5;
