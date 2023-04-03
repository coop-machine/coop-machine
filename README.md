###

# Coop-machine 

coop-machine is a virtual machine dedicated to cooperative processes and cooperating processors.

It has three components : a development environment, a validation tool, and a runtime environment.

## Development environment

## Validation tool

### Prerequisite

This tool requires Postgresql (Version 15) and access to the user 'postgres'

### Installation

* run 'psql' as the user 'postgres'
* create the user 'coop'
* create the database 'coop' and grant its ownership to the user 'coop'
* connect to the database 'coop' as the user 'coop'
* run the following two scripts : tables.sql and procedures.sql (e.g. using the following command : '\i <script path>'
  
  The validation tool is now ready !
  
### How to use
  
* fill the references tables (from table R1 to R10)
* fill the integration tables (from table R11 to R15)
* start the validation procedure using the following command : 'SELECT validation();'
* check table R17 that log every error that occured during the procedure 
  
  NOTE : you can check the comments for more information about these tables, attributes and procedures  (either from the tables.sql and procedures.sql scripts or directly from PSQL ([see COMMENTS](https://www.postgresql.org/docs/current/sql-comment.html))
  
 ### Test datasets
  
we provides 2 scripts for testing purpose each inserting a dataset : 'correct_dataset.sql' and 'incorrect_dataset.sql'
  
## Runtime environment

<!--
**coop-machine/coop-machine** is a ✨ _special_ ✨ repository because its `README.md` (this file) appears on your GitHub profile.

Here are some ideas to get you started:

- 🔭 I’m currently working on ...
- 🌱 I’m currently learning ...
- 👯 I’m looking to collaborate on ...
- 🤔 I’m looking for help with ...
- 💬 Ask me about ...
- 📫 How to reach me: ...
- 😄 Pronouns: ...
- ⚡ Fun fact: ...
-->
