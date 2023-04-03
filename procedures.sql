/*

cette procédure valide les choses suivantes :

que les opérations se succèdent dans un ordre cohérent avec les références de la table R6
que les coprocessus contiennent plus d'une opération
que les coprocessus sont inités par des opérations initiales référencées dans la table R7
que les coprocessus sont terminés par des opérations terminales référencées dans la table R8
que les valeurs des variables impactées par des opérations sont cohérentes avec les références de la table R10

*/

create or replace function validation() returns void
as $$

DECLARE

Log_counter integer; -- stocke la prochaine valeur de la sequence 'logcounter'
Nb_operations integer; -- stocke le nombre d'opérations du coprocessus traité
Count_operations integer; -- compteur d'opérations traitées d'un coprocessus
Test_init integer; -- stocke le resultat du test visant à déterminer si une opération est initiale pour un coprocessus
Test_terminal integer; -- stocke le resultat du test visant à déterminer si une opération est terminale pour un coprocessus

Ref_value varchar;

Current_operation record; -- stocke l'enregistrement correspondant à l'opération en cours de traitement
Previous_operation record; -- stocke l'enregistrement correspondant à l'opération précédement traitée
Processus_record record; -- stocke l'enregistrement correspondant au processus en cours de traitement
Coprocessus_record record; -- stocke l'enregistrement correspondant au coprocessus en cours de traitement
Temp record;
Variable record; -- -- stocke l'enregistrement correspondant à la variable en cours de traitement

curseur_processus refcursor;  -- curseur sur des processus cooperatifs
curseur_coprocessus refcursor; -- curseur sur des coprocessus
curseur_operations refcursor; -- curseur sur des opérations
curseur_variable refcursor; -- curseur sur des variables

BEGIN

-- TODO traduire l'ensemble des commentaires en anglais

-- mise à jours de la vue matérialisée
REFRESH MATERIALIZED VIEW seq;

-- récupération des processus coopératifs
open curseur_processus for
select *
from R12
order by A1;

/*
  boucle A sur l'ensemble des processus cooperatifs
*/

  LOOP
      -- récupération du prochain processus à traiter
      fetch curseur_processus into processus_record;

      -- si plus de processus à traiter -> la validation est terminée on sort de la boucle
      IF not found then
        raise notice 'plus aucun processus a valider';
        close curseur_processus;
        EXIT;
      end IF;

      RAISE notice 'traitement processus %', processus_record.A1;

      -- récupérations des coprocessus associés à ce processus
      open curseur_coprocessus for
      select *
      from R13
      where R13.A2 = processus_record.A1
      order by A1,A2,A3;

/*
    debut boucle B sur l'ensemble des coprocessus
*/
      LOOP

        -- récupérations du prochain coprocessus associé à ce processus
        fetch curseur_coprocessus into coprocessus_record;

        -- si plus de coprocessus à traiter -> on passe au prochain processus
        IF not found then
          raise notice 'plus aucun coprocessus a valider pour ce processus';
          close curseur_coprocessus;
          EXIT;
        end IF;

        RAISE notice 'traitement du coprocessus %,%,%',
        coprocessus_record.A1,
        coprocessus_record.A2,
        coprocessus_record.A3;

        -- récupérations des opérations associées à ce coprocessus
        open curseur_operations for
        select *
        from R14
        where
        R14.A1 = coprocessus_record.A1 AND
        R14.A2 = coprocessus_record.A2 AND
        R14.A3 = coprocessus_record.A3
        order by
        R14.A1, R14.A2, R14.A3, R14.A4;

        -- récupération du nombre d'opérations associées à ce coprocessus
        select count(A1) into Nb_operations
        from R14
        where
        R14.A1 = coprocessus_record.A1 AND
        R14.A2 = coprocessus_record.A2 AND
        R14.A3 = coprocessus_record.A3;

        /*
          Notes :
                   si le nombre d'opération est inferieur à deux, ce n'est pas un coprocessus

                   un coprocessus peut réaliser différentes séquences d'opérations,
                   le nombre d'opérations effectuées par un coprocessus n'est donc pas prédictible
        */
        IF Nb_operations < 2
          then
          RAISE notice 'une seule operation trouvee -> invalidation';

          -- Log du message d'invalidation
          select nextval('Logcounter') into Log_counter;
          insert into R17
          (A1,A2,A3,A4,A5,A6)
          VALUES
          (Log_counter,
          1,
          Current_operation.A1,
          Current_operation.A2,
          Current_operation.A3,
          Current_operation.A4 );

          close curseur_operations;
          CONTINUE; -- on passe directement au prochain coprocessus
        END IF;

        Count_operations := 0;
/*
        debut boucle C sur l'ensemble des operations
*/

        LOOP

        -- récupérations de la prochaine opération
        fetch curseur_operations into Current_operation;

        -- si plus d'opération à traiter -> on passe au prochain coprocessus
        IF not found then
          raise notice 'plus aucune operation a valider';
          close curseur_operations;
          EXIT;
        END IF;

        Count_operations := Count_operations + 1 ;

        RAISE notice 'traitement de l''operations : %,%,%,%',
        Current_operation.A1,
        Current_operation.A2,
        Current_operation.A3,
        Current_operation.A4;


          RAISE notice 'traitement des valeurs de variables pour l''operations %,%,%,%',
          Current_operation.A1,
          Current_operation.A2,
          Current_operation.A3,
          Current_operation.A4;

          -- récupérations des variables associés à cette opération
          open curseur_variable for
          select *
          from R15
          where
          R15.A1 = Current_operation.A1 AND
          R15.A2 = Current_operation.A2 AND
          R15.A3 = Current_operation.A3 AND
          R15.A4 = Current_operation.A4
          order by
          A5;

/*
    debut boucle D sur l'ensemble des variables impactées par cette operation
*/

        LOOP

          -- récupérations de la prochaine variable
          fetch curseur_variable into Variable;

          -- si plus de variable à traiter -> on passe à la prochaine opération
          IF not found then
            raise notice 'plus de variable a valider';
            close curseur_variable;
            EXIT;
          end IF;

          raise notice 'traitement de la variable %', Variable.A5;

          -- on récupère le type de copprocessus et le type d'opération associés à cette variable
          select R13.A4 as Tcoprocessus , R14.A6 as Toperation into Temp
          from R13, R14
          where
          R14.A1 = Variable.A1 AND
          R14.A2 = Variable.A2 AND
          R14.A3 = Variable.A3 AND
          R14.A4 = Variable.A4 AND
          R13.A1 = Variable.A1 AND
          R13.A2 = Variable.A2 AND
          R13.A3 = Variable.A3;

          -- on vérifie que la valeur de cette variable correspond à la référence pour ce type d'opération, ce type de coprocessus et ce type de variable
          select R10.A4 into ref_value from R10
          WHERE
          R10.A1 = Variable.A5 AND
          R10.A2 = Temp.Tcoprocessus AND
          R10.A3 = Temp.Toperation AND
          R10.A4 = Variable.A6;

          IF not found
            then
            raise notice 'valeur incohérente -> invalidation';

            -- Log du message d'invalidation
            select nextval('Logcounter') into Log_counter;
            insert into R17
            (A1,A2,A3,A4,A5,A6)
            VALUES
            (Log_counter,
            2,
            Current_operation.A1,
            Current_operation.A2,
            Current_operation.A3,
            Current_operation.A4 );

            close curseur_variable;
            EXIT;
          end IF;

          raise notice 'valeur Coherente';

        end loop; -- fin boucle D

        -- si l'opération est la première du coprocessus, on regarde si elle existe dans la liste des opérations initiales pour ce coprocessus
        IF Count_operations = 1
          then
          select init into test_init from seq
          where
          AReference_type_operation_A = Current_operation.A6 and
          AReference_type_coprocessus = coprocessus_record.A4;

          IF not found then
            raise notice 'l''operation : %,%,%,% n''est pas une operation initiale pour ce coprocessus -> invalidation',
            Current_operation.A1,
            Current_operation.A2,
            Current_operation.A3,
            Current_operation.A4;

            -- Log du message d'invalidation
            select nextval('Logcounter') into Log_counter;
            insert into R17
            (A1,A2,A3,A4,A5,A6)
            VALUES
            (Log_counter,
            3,
            Current_operation.A1,
            Current_operation.A2,
            Current_operation.A3,
            Current_operation.A4 );

            close curseur_operations;
            EXIT;
          end IF;

          IF test_init = 0
            then
            raise notice 'l''operation : %,%,%,% n''est pas une operation initiale pour ce coprocessus -> invalidation',
            Current_operation.A1,
            Current_operation.A2,
            Current_operation.A3,
            Current_operation.A4;

            -- Log du message d'invalidation
            select nextval('Logcounter') into Log_counter;
            insert into R17
            (A1,A2,A3,A4,A5,A6)
            VALUES
            (Log_counter,
            3,
            Current_operation.A1,
            Current_operation.A2,
            Current_operation.A3,
            Current_operation.A4 );

            close curseur_operations;
            EXIT;
          END IF;

          RAISE notice 'l''operations : %,%,%,% est initiale pour ce coprocessus',
          Current_operation.A1,
          Current_operation.A2,
          Current_operation.A3,
          Current_operation.A4;
        END IF;

        -- si l'opération n'est pas la première du coprocessus, on verifie que ces deux opérations appartiennent à une séquence valide pour ce coprocessus
        IF Count_operations > 1
          then
          RAISE notice 'traitement du couple d''operations A : %,%,%,% et B : %,%,%,%',
          Previous_operation.A1,
          Previous_operation.A2,
          Previous_operation.A3,
          Previous_operation.A4,
          Current_operation.A1,
          Current_operation.A2,
          Current_operation.A3,
          Current_operation.A4;

          IF exists
          (
            select * from seq
            where
            AReference_type_operation_A = Previous_operation.A6 and
            AReference_type_operation_B = Current_operation.A6 AND
            AReference_type_coprocessus = coprocessus_record.A4
          )
            then
            raise notice 'sequence trouvee';
          ELSE
            raise notice 'sequence introuvable -> invalidation';

            -- Log du message d'invalidation
            select nextval('Logcounter') into Log_counter;
            insert into R17
            (A1,A2,A3,A4,A5,A6)
            VALUES
            (Log_counter,
            4,
            Previous_operation.A1,
            Previous_operation.A2,
            Previous_operation.A3,
            Previous_operation.A4 );

            select nextval('Logcounter') into Log_counter;
            insert into R17
            (A1,A2,A3,A4,A5,A6)
            VALUES
            (Log_counter,
            4,
            Current_operation.A1,
            Current_operation.A2,
            Current_operation.A3,
            Current_operation.A4 );


            close curseur_operations;
            EXIT;
          END IF;

          /*
          TEST :
            si l'operation est terminale et qu'il s'agit bien de la dernière opération pour ce coprocessus, celui-ci est validé
            Si l'opération est terminale et qu'il ne s'agit pas de la dernière opération pour ce coprocessus, celui-ci est invalidé
            Si l'opération n'est pas terminale et qu'il s'agit de la dernière opération pour ce coprocessus, celui-ci est invalidé
            Si l'opération n'est pas terminale et qu'il ne s'agit pas de la dernière opération pour ce coprocessus, on continue
          */

          select termi into test_terminal from seq where
          AReference_type_operation_B = Current_operation.A6 and
          AReference_type_operation_A = Previous_operation.A6 and
          AReference_type_coprocessus = coprocessus_record.A4;

          IF test_terminal != 0
            then
            IF Count_operations = Nb_operations
              then
              raise notice 'l''operations : %,%,%,% est terminale pour ce coprocessus et le nombre d''operations est coherent',
              Current_operation.A1,
              Current_operation.A2,
              Current_operation.A3,
              Current_operation.A4;
              close curseur_operations;
              EXIT;
            ELSE
              raise notice 'l''operations : %,%,%,% est terminale pour ce coprocessus mais le nombre d''operations est incoherent -> invalidation',
              Current_operation.A1,
              Current_operation.A2,
              Current_operation.A3,
              Current_operation.A4;

              -- Log du message d'invalidation
              select nextval('Logcounter') into Log_counter;
              insert into R17
              (A1,A2,A3,A4,A5,A6)
              VALUES
              (Log_counter,
              5,
              Current_operation.A1,
              Current_operation.A2,
              Current_operation.A3,
              Current_operation.A4 );

              close curseur_operations;
              EXIT;
            END IF;
          END IF;

        END IF;

        -- on remplace l'opération précédente par l'opération actuelle avant de passer à la prochaine opération
        Previous_operation := Current_operation;

        CONTINUE;

        end loop; -- fin boucle C

      end loop; -- fin boucle B

  end loop; -- fin boucle A

END

$$ LANGUAGE plpgsql;

/*

  select validation();

*/
