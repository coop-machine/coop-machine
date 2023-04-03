
Insert into R1 -- références de type de coprocesseur (conceptuel)
(A1)
values
(1), -- cases (loci locus)
(2); -- personnages

Insert into R2 -- références de type de processus cooperatifs
(A1)
values
(1); -- déplacement

Insert into R3 -- références de type de coprocessus r3
(A1,A2,A3)
values
(1,2,1), -- déplacement par personnage
(2,1,1), -- déplacement par case d'accueil
(3,1,1); -- déplacement par case de destination

Insert into R4 -- références de type d'opération
(A1)
values
(1), -- déplacement 1 (personnage)
(2), -- déplacement 2 (personnage)
(3), -- déplacement 1 (case d'accueil)
(4), -- déplacement 2 (case d'accueil)
(5), -- déplacement 2 bis (case d'accueil) - echec pas de case de destination
(6), -- déplacement 1 (case de destination)
(7), -- déplacement 2 (case de destination)
(8), -- déplacement 3 (case de destination) - reussite
(9); -- déplacement 3 bis (case de destination) - echec

Insert into R5 -- références de type d'opérations de coprocessus (avec timeout)
(A1,A2,A3)
values
(1,1,0),  -- déplacement par personnage - déplacement 1 (personnage)
(1,2,0),  -- déplacement par personnage - déplacement 2 (personnage)
(2,3,0), -- déplacement par case d'accueil - déplacement 1 (case d'accueil)
(2,4,0), -- déplacement par case d'accueil - déplacement 2 (case d'accueil)
(2,5,0), -- déplacement par case d'accueil - déplacement 2 bis (case d'accueil) - echec pas de case de destination
(3,6,0), -- déplacement par case de destination - déplacement 1 (case de destination)
(3,7,0), -- déplacement par case de destination - déplacement 2 (case de destination)
(3,8,0), -- déplacement par case de destination - déplacement 3 (case de destination) - reussite
(3,9,0); -- déplacement par case de destination - déplacement 3 bis (case de destination) - echec


Insert into R6 -- références de successions d'opérations
(A1,A2,A3)
values
(1,1,2), -- Personnage - déplacement - demande déplacement à case accueil - 1 - 2
(2,3,4), -- Case d'accueil - déplacement - demande déplacement à case de destination - 1 - 2
(2,3,5), -- Case d'accueil - déplacement - pas de case de destination - 1 - 2 bis
(3,6,7), -- Case de destination - déplacement - préparation - 1 - 2
(3,7,8), -- Case de destination - déplacement - acceptation - 2 - 3
(3,7,9); -- Case de destination - déplacement - refusation - 2 - 3 bis


Insert into R7 -- références d'opérations initiant un coprocessus
(A1,A2)
values
(1,1), -- déplacement par personnage
(2,3), -- déplacement par case d'accueil
(3,6); -- déplacement par case de destination

Insert into R8 -- références d'opérations terminant un coprocessus
(A1,A2)
values
(1,2), -- déplacement par personnage
(2,4), -- déplacement par case d'accueil
(2,5), -- déplacement par case d'accueil
(3,8), -- déplacement par case de destination
(3,9); -- déplacement par case de destination

Insert into R9 -- références de type de variable
(A1)
values
(1); -- emplacement de case

Insert into R10 -- références de valeurs de variables
(A1,A2,A3,A4) -- (type variable, type de coprocessus, type d'opération, valeur apres opération)
values
(1,3,8,'occupee'), -- l'emplacement accueille le personnage (reussite du déplacement)
(1,3,9,'inoccupee'); -- emplacement vide (echec du déplacement)

Insert into R11 -- des coprocesseurs
(A1,A2)
values
(1,1), -- case A
(2,1), -- case B
(3,1), -- case C
(4,2); -- personnage 1

Insert into R12 -- des processus cooperatifs
(A1,A2)
values
(1,1),
(2,1),
(3,1);

Insert into R13 -- des coprocessus
(A1,A2,A3,A4)
values
-- processus 1
(4,1,1,1), -- deplacement du personnage 1 de la case A à la case B reussite -> personnage 1 (id_coprocess 1)
(1,1,1,2), -- deplacement du personnage 1 de la case A à la case B reussite -> case A (id_coprocess 1)
(2,1,1,3), -- deplacement du personnage 1 de la case A à la case B reussite -> case B (id_coprocess 1)
-- processus 2
(4,2,2,1), -- deplacement du personnage 1 de la case B à la case D echec pas de case D -> personnage 1 (id_coprocess 2)
(2,2,2,2), -- deplacement du personnage 1 de la case B à la case D echec pas de case D -> case B (id_coprocess 2)
-- processus 3
(4,3,3,1), -- deplacement du personnage 1 de la case B à la case C echec -> personnage 1 (id_coprocess 3)
(2,3,3,2), -- deplacement du personnage 1 de la case B à la case C echec -> case B (id_coprocess 3)
(3,3,1,3); -- deplacement du personnage 1 de la case B à la case C echec -> case C (id_coprocess 1)

Insert into R14 -- des opérations
(A1,A2,A3,A4,A5,A6)
values
-- processus 1
(4,1,1,1,0,1), -- déplacement reussi / ref 1 - Personnage (4) - coprocessus 1 - deplacement rang 1
(4,1,1,2,0,2), -- déplacement reussi / ref 2 - Personnage (4) - coprocessus 1 - deplacement rang 2
(1,1,1,1,0,3), -- déplacement reussi / ref 3 - case A (1) -
(1,1,1,2,0,4), -- déplacement reussi / ref 4 - case A (1) -
(2,1,1,1,0,6), -- déplacement reussi / ref 6 - case B (2) -
(2,1,1,2,0,7), -- déplacement reussi / ref 7 - case B (2) -
(2,1,1,3,0,8), -- déplacement reussi / ref 8 - case B (2) -
-- processus 2
(4,2,2,1,0,1), -- déplacement échoué pas de case D / ref 1 - Personnage (4)
(4,2,2,2,0,2), -- déplacement échoué pas de case D / ref 2 - Personnage (4)
(2,2,2,1,0,3), -- déplacement échoué pas de case D / ref 3 - case B (2)
(2,2,2,2,0,5), -- déplacement échoué pas de case D / ref 5 - case B (2)
-- processus 3
(4,3,3,1,0,1), -- déplacement échoué / ref 1 - Personnage (4)
(4,3,3,2,0,2), -- déplacement échoué / ref 2 - Personnage (4)
(2,3,3,1,0,3), -- déplacement échoué / ref 3 - case B (2)
(2,3,3,2,0,4), -- déplacement échoué / ref 4 - case B (2)
(3,3,1,1,0,6), -- déplacement échoué / ref 6 - case C (3)
(3,3,1,2,0,7), -- déplacement échoué / ref 7 - case C (3)
(3,3,1,3,0,9); -- déplacement échoué / ref 9 - case C (3)

insert into R15
(A1,A2,A3,A4,A5,A6)
VALUES
(2,1,1,3,1,'occupee'),
(3,3,1,3,1,'inoccupee');
