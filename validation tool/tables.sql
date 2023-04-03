


-- La codification des noms permet de simplement changer les commentaires sans bousculer le schema relationnel


create table R1 -- références de type de coprocesseur (conceptuel)
(
  A1 INT not null, -- référence de type de coprocesseur
  PRIMARY KEY (A1)
);

create table R2 -- références de type de processus cooperatifs
(
  A1 INT not null, -- référence de type de processus cooperatif
  PRIMARY KEY (A1)
);

/* un coprocessus est mono coprocesseur et mono processus cooperatif */

create table R3 -- références de type de coprocessus
(
  A1 INT not null, -- référence de type de coprocessus
  A2 INT not null, --  référence de type de coprocesseur
  A3 INT not null, -- référence de type de processus cooperatif
  PRIMARY KEY (A1),
  FOREIGN KEY (A2) REFERENCES R1(A1),
  FOREIGN KEY (A3) REFERENCES R2(A1)
);

create table R4 -- références de type d'opération
(
  A1 INT not null, -- référence de type d'opération
  PRIMARY KEY (A1)
);

create table R5 -- références de type d'opérations de coprocessus
(
  A1 INT not null, -- référence de type de coprocessus
  A2 INT not null, -- référence de type d'opération
  A3 INT not null, --  temps avant timeout
  PRIMARY KEY (A1,A2),
  FOREIGN KEY (A1) REFERENCES R3(A1),
  FOREIGN KEY (A2) REFERENCES R4(A1)
);


create table R6 -- références de successions d'opérations
(
  A1 INT not null, -- référence de type de coprocessus
  A2 INT not null, -- référence de type d'opération précédente
  A3 INT not null, -- référence de type d'opération suivante
  PRIMARY KEY (A1,A2,A3),
  FOREIGN KEY (A1,A2) REFERENCES R5(A1,A2),
  FOREIGN KEY (A1,A3) REFERENCES R5(A1,A2)
);

/*
référence l'ensemble des opérations initiant un coprocessus
*/
create table R7 -- références d'opérations initiant un coprocessus
(
  A1 INT not null, -- référence de type de coprocessus
  A2 INT not null, -- référence de type d'opération
  PRIMARY KEY (A1,A2),
  FOREIGN KEY (A1,A2) REFERENCES R5(A1,A2)
);

/*
référence l'ensemble des opérations terminant un coprocessus
*/
create table R8 -- références d'opérations terminant un coprocessus
(
  A1 INT not null, -- référence de type de coprocessus
  A2 INT not null, -- référence de type d'opération
  PRIMARY KEY (A1,A2),
  FOREIGN KEY (A1,A2) REFERENCES R5(A1,A2)
);

create table R9 -- références de type de variable
(
  A1 INT not null, -- référence de type de variable
  PRIMARY KEY (A1)
);

create table R10 -- références de valeurs de variables
(
  A1 INT not null, -- référence de type de variable
  A2 INT not null, -- référence de type de coprocessus
  A3 INT not null, -- référence de type d'opération
  A4 varchar not null, -- référence de valeur après opération
  PRIMARY KEY (A1,A2,A3),
  foreign key (A1) references R9(A1),
  foreign key (A2,A3) references R5(A1,A2)
);


/*
l'ensemble des tables d'intégration peuvent être segmentées/distribuées en utilisant les différents identifiant (coprocesseur,processus,coprocessus,opération)
*/


create table R11 -- des coprocesseurs
(
    A1 INT not null, -- identifiant d'un coprocesseur
    A2 INT not null, -- référence de type de coprocesseur
    PRIMARY KEY(A1),
    FOREIGN KEY (A2) REFERENCES R1(A1)
);
/*
Un processus est lancé par un coprocesseur, celui-ci lui donnant son identifiant,
cet identifiant sera donné aux autres coprocesseurs qui collaborent à la réalisation de ce processus
*/

create table R12 -- des processus cooperatifs
(
    A1 INT not null, -- identifiant d'un processus
    A2 INT not null, -- référence de type de processus cooperatif
    PRIMARY KEY (A1),
    FOREIGN KEY (A2) REFERENCES R2(A1)
);

/*
NOTE : il serait possible d'uniquement utiliser l'identifiant du coprocessus pour la clef primaire
il s'agit ici d'optimisation via la segmentation des identifiants afin ne pas avoir un nombre incalculable de numero de coprocessus
*/
create table R13 -- des coprocessus
(
    A1 INT not null, -- identifiant d'un coprocesseur
    A2 INT not null, -- identifiant d'un processus
    A3 INT not null, -- identifiant d'un coprocessus
    A4 INT not null, -- référence de type de coprocessus
    PRIMARY KEY (A1,A2,A3),
    FOREIGN KEY (A1) REFERENCES  R11(A1),
    FOREIGN KEY (A2) REFERENCES  R12(A1),
    FOREIGN KEY (A4) REFERENCES  R3(A1)
);


create table R14 -- des opérations
(
    A1 INT not null, -- identifiant d'un coprocesseur
    A2 INT not null, -- identifiant d'un processus
    A3 INT not null, -- identifiant d'un coprocessus
    A4 INT not null, -- numero d'opération dans le coprocessus
    A5 INT not null, -- compteur pour timeout
    A6 INT not null, -- référence de type d'opération
    PRIMARY KEY (A1,A2,A3,A4),
    FOREIGN KEY (A6) REFERENCES  R4(A1),
    FOREIGN KEY (A1,A2,A3) REFERENCES  R13(A1,A2,A3)
);

create table R15 -- valeurs de variables
  (
    A1 INT not null, -- identifiant d'un coprocesseur
    A2 INT not null, -- identifiant d'un processus
    A3 INT not null, -- identifiant d'un coprocessus
    A4 INT not null, -- numero d'opération dans le coprocessus
    A5 INT not null, -- référence de type de variable
    A6 varchar not null, -- valeur après opération
    PRIMARY KEY (A1,A2,A3,A4,A5),
    foreign key (A5) references R9(A1),
    foreign key (A1,A2,A3,A4) references R14(A1,A2,A3,A4)
  );

  /*
  creation de la vue matérialisée seq qui comprend les reférences de séquence d'opérations
  associées à des flags indiquant si l'opération précédente est une opération initiale et l'opération suivante une opération terminale
  */

  create materialized view seq as
  select
  AReference_type_coprocessus,
  AReference_type_operation_A,
  AReference_type_operation_B,
  coalesce(AReference_type_operation_init,0) as init,
  coalesce(BReference_type_operation_termi,0) as termi
  from

    -- sous requêtes pour les opérations initiales
    (select
    R6.A1 as AReference_type_coprocessus,
    R6.A2 as AReference_type_operation_A,
    R6.A3 as AReference_type_operation_B ,
    R7.A2 as AReference_type_operation_init
    from
    R6 LEFT OUTER JOIN R7 ON
    R6.A2 = R7.A2 AND
    R6.A1 = R7.A1

    order by
    AReference_type_operation_A) as init,

    -- sous requêtes pour les opérations terminales
    (select
    R6.A1 as BReference_type_coprocessus,
    R6.A2 as BReference_type_operation_A,
    R6.A3 as BReference_type_operation_B ,
    R8.A2 as BReference_type_operation_termi
    from

    R6 LEFT OUTER JOIN R8 ON
    R6.A3 = R8.A2 AND
    R6.A1 =  R8.A1

    order by
    BReference_type_operation_A) as termi

  where
  init.AReference_type_coprocessus = termi.BReference_type_coprocessus AND
  init.AReference_type_operation_A = termi.BReference_type_operation_A AND
  init.AReference_type_operation_B = termi.BReference_type_operation_B
  order by
  AReference_type_coprocessus;

  /*
  FIN DE LA CREATION DE LA vue matérialisée seq
  */

create table R16 -- références de codes d'invalidation
(
  A1 INT not null, -- référence de code d'invalidation
  PRIMARY KEY (A1)
);

-- insertion des codes d'invalidation
insert into R16
(A1)
VALUES
(1), -- une seule opération trouvée dans un coprocessus
(2), -- valeur de variable incohérente avec celle de la référence
(3), -- l'opération est la première du coprocessus mais est introuvable dans la table des références d'opérations initiant un coprocessus
(4), -- les deux opérations successives sont introuvables dans la table des références de successions d'opérations
(5), -- l'opération n'est pas la dernière du processus mais est présente dans la table des références d'opérations terminant un coprocessus
(6); -- l'opération est la dernière du processus mais est introuvable dans la table des références d'opérations terminant un coprocessus


create table R17 -- logs de la validation
(
  A1 INT not null, -- identifiant du log
  A2 INT not null, -- référence de code d'invalidation
  A3 INT not null, -- identifiant d'un coprocesseur
  A4 INT not null, -- identifiant d'un processus
  A5 INT not null, -- identifiant d'un coprocessus
  A6 INT not null, -- numero d'opération dans le coprocessus
  PRIMARY KEY (A1),
  FOREIGN KEY (A2) REFERENCES R16(A1),
  foreign key (A3,A4,A5,A6) references R14(A1,A2,A3,A4)
);

-- utilisé dans le programme de validation pour identifier les logs
create sequence Logcounter start 1; -- select nextval('Logcounter');
