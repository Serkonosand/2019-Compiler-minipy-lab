# 现在采用非指针类型的YYSTYPE制作，文件更新在NonPointer文件夹中
#### 运行方式
**Use makefile**
*using C++11 standard*
```
make
./a.out
```
**Or**
```
yacc -d minipy-lab.y
lex minipy-lab.l
g++ y.tab.c
./a.out
```
#### DEBUG
**Run `. rundebug.sh` or `./rundebug.sh`**
Add debug input example in file `rundebug.sh`
#### Note
* When using C++11
    * In file `lex.yy.c`, `YY_(Msgid)` is defined like this
        ```C++
        #ifndef YY_
        # if defined YYENABLE_NLS && YYENABLE_NLS
        #  if ENABLE_NLS
        #   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
        #   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
        #  endif
        # endif
        # ifndef YY_
        #  define YY_(Msgid) Msgid
        # endif
        #endif
        ```
        And when it's used like `YY_("syntax error")`, we will get a g++ warning like
        ```
        warning: ISO C++ forbids converting a string constant to ‘char*’ [-Wwrite-strings]
            yyerror (YY_("memory exhausted"));
        ```
# 现在采用非指针类型的YYSTYPE制作，文件更新在NonPointer文件夹中
#### 运行方式
**Use makefile**
*using C++11 standard*
```
make
./a.out
```
**Or**
```
yacc -d minipy-lab.y
lex minipy-lab.l
g++ y.tab.c
./a.out
```
#### DEBUG
**Run `. rundebug.sh` or `./rundebug.sh`**
Add debug input example in file `rundebug.sh`
#### Note
* When using C++11
    * In file `lex.yy.c`, `YY_(Msgid)` is defined like this
        ```C++
        #ifndef YY_
        # if defined YYENABLE_NLS && YYENABLE_NLS
        #  if ENABLE_NLS
        #   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
        #   define YY_(Msgid) dgettext ("bison-runtime", Msgid)
        #  endif
        # endif
        # ifndef YY_
        #  define YY_(Msgid) Msgid
        # endif
        #endif
        ```
        And when it's used like `YY_("syntax error")`, we will get a g++ warning like
        ```
        warning: ISO C++ forbids converting a string constant to ‘char*’ [-Wwrite-strings]
            yyerror (YY_("memory exhausted"));
        ```
        Maybe we should change the definition `#  define YY_(Msgid) Msgid` into `#  define YY_(Msgid) ((char *)Msgid)`