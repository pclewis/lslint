#include <stdio.h>
#include <string.h>
#include "lslmini.hh"
#include "logger.hh"

char *builtins_file = NULL;
extern char *builtins_txt[];

struct _TypeMap {
  char *name;
  LST_TYPE type;
} types[] = {
  {"void",    LST_NULL},
  {"integer", LST_INTEGER},
  {"float",   LST_FLOATINGPOINT},
  {"string",  LST_STRING},
  {"key",     LST_KEY},
  {"vector",  LST_VECTOR},
  {"rotation",LST_QUATERNION},
  {"list",    LST_LIST},
  {NULL,      LST_ERROR}
};

LLScriptType *str_to_type(char *str) {
  for (int i = 0; types[i].name != NULL; ++i) {
    if ( strcmp(types[i].name, str) == 0 )
      return LLScriptType::get(types[i].type);
  }
  fprintf(stderr, "invalid type in builtins.txt: %s\n", str);
  exit(EXIT_FAILURE);
  return LLScriptType::get(LST_ERROR);
}

void LLScriptScript::define_builtins() {
   LLScriptFunctionDec *dec = NULL;
   FILE *fp = NULL;
   char buf[1024];
   char original[1024];
   char *ret_type = NULL;
   char *name = NULL;
   char *ptype = NULL, *pname = NULL;
   int line = 0;

   if(builtins_file != NULL) {
      fp = fopen(builtins_file, "r");

      if (fp==NULL) {
         snprintf(buf, 1024, "couldn't open %s", builtins_file);
         perror(buf);
         exit(EXIT_FAILURE);
      }
   }

   while (1) {
      if (fp) {
         if (fgets(buf, 1024, fp)==NULL)
            break;
      } else {
         if (builtins_txt[line]==NULL)
            break;
         strncpy(buf, builtins_txt[line], 1024);
         ++line;
      }

      strcpy(original, buf);

      ret_type = strtok(buf,  " (),");

      if ( ret_type == NULL ) {
         fprintf(stderr, "error parsing %s: %s\n", builtins_file, original);
         exit(EXIT_FAILURE);
         return;
      }

      if (!strcmp(ret_type, "const")) {
         ret_type = strtok(NULL, " (),");
         name     = strtok(NULL, " (),");

         if ( ret_type == NULL || name == NULL ) {
            fprintf(stderr, "error parsing %s: %s\n", builtins_file, original);
            exit(EXIT_FAILURE);
            return;
         }

         define_symbol( new LLScriptSymbol(
                  strdup(name), str_to_type(ret_type), SYM_VARIABLE, SYM_BUILTIN
                  ));
      }
      else if (!strcmp(ret_type, "event")) {
         printf("ignoring event\n");
      }
      else {
         name     = strtok(NULL, " (),");

         if ( ret_type == NULL || name == NULL ) {
            fprintf(stderr, "error parsing %s: %s\n", builtins_file, original);
            exit(EXIT_FAILURE);
            return;
         }

         dec = new LLScriptFunctionDec();
         while ( (ptype = strtok(NULL, " (),")) != NULL ) {
            if ( (pname = strtok(NULL, " (),")) != NULL ) {
               dec->push_child(new LLScriptIdentifier( str_to_type(ptype), strdup(pname)));
            }
         }

         define_symbol( new LLScriptSymbol(
                  strdup(name), str_to_type(ret_type), SYM_FUNCTION, SYM_BUILTIN, dec
                  ));
      }
   }
}

