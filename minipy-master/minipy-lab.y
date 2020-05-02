%{
    /* definition */
    #include <cstring>
    #include <stdio.h>
    #include <string.h>
    #include <iostream>
//    #include "minipy-lab.h"

    #define LIST 100
    #define NONE 101
    #define LISTITEM 102
    #define LISTSLICE 103
    #define INFINITY 65535
    #define UNKNOWN_TYPE 128

    struct Val
    {
        int type;
        int addrtype;//取地址赋值的时候要用，分为LISTITEM和LISTSLICE，分别为取一个和取范围
        int symnum;//记录符号表num
        char* attributename;//记录方法名
        int low[10];
        int high[10];
        int depth;//取地址套娃的深度
        int step;
        union
        {
            char* idname;
            int ival;
            double fval;
            char* strval;
            struct List *listval;
        };
        Val();
        // Val &operator= (const Val &assign_val);
        void deep_copy(const Val &assign_val);
        ~Val();
    };

    // TODO: maybe unused?
    // const Val UNKNOWN_VAL;

    struct List
    {
        struct ListNode *head;
        struct ListNode *tail;
        int length;
        List();
        ~List();
        void delete_node(int index);
        void insert(int index, Val *insert_val);
        List *add_to_list(Val *add_val);
        Val *value(const int index);
    };

    struct ListNode
    {
        struct Val nodeval;
        struct ListNode *next;
        ~ListNode();
    };


     typedef struct
    {
    		int reval;//保留值，用来判断是右值还是左值，从而确定是否将数据更新到符号表里
        char* id_name;
        Val id_value;
    } SymNode;


    SymNode Sym[100];
    int createflag = 0;
    int n = 0;
    int flag = 1;


    #define YYSTYPE Val
    #include "lex.yy.c"
    using namespace std;
    void yyerror(char*);

    // int yylex(void);
    int LookUp(char *idname)
    {
        int i;
        for(i = 1;i <= 100;i++)
        {
            if(Sym[i].id_name == NULL)
                return 0;
            if(strcmp(idname,Sym[i].id_name) == 0)
                return i;
        }
        return 0;
    }
    int CreateSym(char *idname)
    {
        int flag = LookUp(idname);
        if(flag == 0)
        {
            n++;
            int length = strlen(idname);
            Sym[n].id_name = (char*)malloc(sizeof(char)*(length+1));
            strncpy(Sym[n].id_name,idname,length+1);
            Sym[n].id_value.depth = 0;
 						Sym[n].reval=0;
            return n;
        }
        else
            return flag;
    }
    /*遍历链表记录链表长度到length里*/
    int CountLength(List *list_val)
    {
    		ListNode *tempnode;
    		tempnode = list_val->head;
    		int length = 0;
    		if(list_val->head==NULL)
    		{
    				return(0);
    		}
    		while(tempnode != list_val->tail)
    		{
    				length++;
    				tempnode = tempnode->next;
    		}
    		length = length + 1;
    		return(length);
    }
    List* AddToList(Val *x, Val *y)
    {
        ListNode *tmp = (ListNode*)malloc(sizeof(ListNode));

        List *list;
        tmp->nodeval = (*y);
        tmp->next = NULL;
//        if(x->listval->tail == NULL)	printf("wrong\n");
        (*x).listval->tail->next = tmp;
        (*x).listval->tail = (*x).listval->tail->next;
        (*x).listval->length = CountLength(x->listval);//记录长度
        list = (*x).listval;
        return(list);
    }
    void printlist(List *list)
    {
        ListNode *l = list->head;
        printf("[");
        while(l != NULL)
        {
            switch(l->nodeval.type)
            {
                case INT:
                    printf("%d",l->nodeval.ival);
                    break;
                case REAL:
                    printf("%g",l->nodeval.fval);
                    break;
                case STRING_LITERAL:
                    printf("'%s'",l->nodeval.strval);
                    break;
                case LIST:
                    printlist(l->nodeval.listval);
                    break;
                case NONE:
                    printf("None");
            }
            if(l == list->tail)
                break;
            printf(",");
            l = l->next;
        }
        printf("]");
    }
    List *MulList(List *x, int n)
    {
        ListNode *a;
        ListNode *b = x->tail;
        ListNode *tmp;
        while(n != 1)
        {
            a = x->head;
            while (a != b)
            {
                tmp = (ListNode*)malloc(sizeof(ListNode));
								tmp->nodeval = a->nodeval;
								tmp->next = NULL;
								x->tail->next = tmp;
								x->tail = x->tail->next;
								a = a->next;
            }
            tmp = (ListNode*)malloc(sizeof(ListNode));
						tmp->nodeval = a->nodeval;
						tmp->next = NULL;
						x->tail->next = tmp;
            x->tail = x->tail->next;
						n--;
        }
        return x;
    }
    List *CopyList(List *x)
    {
        List *a = (List*)malloc(sizeof(List));
        ListNode  *b = x->head;
        ListNode *tmp;
        if(b == NULL)
        {
            a->head = NULL;
            a->tail = NULL;
            a->length = 0;
            return a;
        }
        else
        {
            a->head = (ListNode*)malloc(sizeof(ListNode));
            a->head->nodeval = x->head->nodeval;
            a->tail = a->head;
            a->head->next = NULL;
            b = x->head->next;
            while(b != NULL)
            {
                tmp = (ListNode*)malloc(sizeof(ListNode));
                tmp->nodeval = b->nodeval;
                tmp->next = NULL;
                a->tail->next = tmp;
                a->tail = a->tail->next;
                b = b->next;
            }
            a->length = x->length;//记录长度
            return a;
        }
    }
    void Print(Val x)
    {
        if(x.type == ID)
        {
            int i = CreateSym(x.idname);
            if(Sym[i].id_value.type == INT)
            {
                if(Sym[i].id_value.type != NONE)
                    printf("%d\n",Sym[i].id_value.ival);
            }
            else if(Sym[i].id_value.type == REAL)
                if(Sym[i].id_value.type != NONE)
                    printf("%f\n",Sym[i].id_value.fval);

        }
        if(x.type == INT)
            printf("%d\n",x.ival);
        else if(x.type == REAL)
            printf("%g\n",x.fval);
        else if(x.type == STRING_LITERAL)
        {
            printf("%s\n",x.strval);
        }
        else if(x.type == LIST)
        {
            printlist(x.listval);
            printf("\n");
        }
        else if(x.type == NONE)
            printf("None\n");
        for(int j = 0;j<101;j++)
        {
        		Sym[j].reval=0;
        }
    }

%}

%token ID INT REAL STRING_LITERAL
%left  '+' '-'
%left  '*' '/' '%'
%right UMINUS

%%
Start:
    prompt Lines
;

Lines:
    Lines stat '\n'
    {
        if(flag != 0)
        {
        if($2.type == ID)
        {
            int i = CreateSym($2.idname);
            if(Sym[i].id_value.type == INT)
            {
                if(Sym[i].id_value.type != NONE)
                    printf("%d\n",Sym[i].id_value.ival);
            }
            else if(Sym[i].id_value.type == REAL)
                if(Sym[i].id_value.type != NONE)
                    printf("%f\n",Sym[i].id_value.fval);

        }
        if($2.type == INT)
            printf("%d\n",$2.ival);
        else if($2.type == REAL)
            printf("%g\n",$2.fval);
        else if($2.type == STRING_LITERAL)
        {
            printf("%s\n",$2.strval);
        }
        else if($2.type == LIST)
        {
            printlist($2.listval);
            printf("\n");
        }
        for(int j = 0;j<101;j++)
        {
        		Sym[j].reval=0;
        }
        }
        flag = 1;
    }
    prompt |
    Lines '\n' prompt |
    %empty { $$.type = NONE; }
|
    error '\n'
        { yyerrok; }
;

prompt:
	%empty {
        cout << "miniPy> ";
        $$.type = NONE;
    }
;

stat:
	assignExpr
;

assignExpr:
    atom_expr '=' assignExpr
    {
        if($1.type == ID)
        {
            int i = CreateSym($1.idname);
            Sym[i].id_value = $3;
            $$ = $3;
            $$.symnum = i;
        }
        else if($1.addrtype == LISTITEM)
        {
            ListNode *p = Sym[$1.symnum].id_value.listval->head;
            int i,j,temp;i=0;
            int cnt = Sym[$1.symnum].id_value.depth;
//            printf("%d\n",cnt);
            for(j=0;j<=cnt;)
            {
            		if(Sym[$1.symnum].id_value.low[j]>=0)
                		temp = Sym[$1.symnum].id_value.low[j];
            		else
                		temp = Sym[$1.symnum].id_value.listval->length + Sym[$1.symnum].id_value.low[j];
//                printf("%d\n",temp);
								i=0;
            		while(i<temp)
           		 {
           		 	    i++;
                		p = p->next;
            		}
            		j++;
            		if(j==cnt)	break;
            		/*下面进入套娃中*/
            		else
            		{
            				if(p->nodeval.type == LIST)
            				{
            						p = p->nodeval.listval->head;
            				}
            		}
            }
            p->nodeval = $3;
            $$ = $3;
            $$.symnum == $1.symnum;
        } else if ($1.addrtype == LISTSLICE) {
            $$ = $3;
            if ($3.type != LIST ) {
                yyerror("ERROR: Try to do list method to a non-list value!");
            }
            if ($1.step != 1 && ($1.high[0] - $1.low[0] + 1) / $1.step
                             != $3.listval->length) {
                yyerror("ERROR: List length of slice assign \
                        operation should be equal when step != 1");
            }
            Val *val_list = &Sym[$1.symnum].id_value;
            CountLength($3.listval);
            int i = $1.low[0];
            int j = 0;
            while ((($1.step > 0) ? (i < $1.high[0]) : (i > $1.high[0])) &&
                   j < $3.listval->length) {
                *(val_list->listval->value(i)) = *($3.listval->value(j));
                i += $1.step;
                j++;
            }
            int temp_i = i;
            while (($1.step > 0) ? (i < $1.high[0]) :
                                   (i > $1.high[0])){
                val_list->listval->delete_node(temp_i);
                i += $1.step;
            }
            while (j < $3.listval->length) {
                val_list->listval->insert(i, $3.listval->value(j));
                i++;
                j++;
            }
        }
        else
        {
            yyerror("ERROR : Unable to assign");
            YYERROR;
            break;
        }
        flag = 0;
    }
         |
    add_expr
      {$$ = $1;}
;

number:
        INT {$$ = $1;}|
        REAL{$$ = $1;}
;

factor:
    '+' factor
    {
        $$.type = $2.type;
        if($2.type == INT)
            $$.ival = $2.ival;
        else if($2.type == REAL)
            $$.fval = $2.fval;
    }
         |
    '-' factor %prec UMINUS
    {
        $$.type = $2.type;
        if($2.type == INT)
            $$.ival = -$2.ival;
        else if($2.type == REAL)
            $$.fval = -$2.fval;
    }
         |
    atom_expr
        {
            if($1.type == ID)
            {
                int i = LookUp($1.idname);
                /*-----------------------------*/
                if(i != 0)
                {
                    Sym[i].id_value.depth=0;
                    $$ = Sym[i].id_value;
                }
                else
                {
                    printf("name '%s' is not defined",$1.idname);
                    yyerror("");
                    YYERROR;
                }
                /*-----------------------------*/
            }
            $1.type = NONE;
        }
;

atom:
    ID |
    STRING_LITERAL |
    List |
    number {$$ = $1;}
;

slice_op:
    %empty { $$.type =  NONE; };
|
    ':' { $$.type = NONE; }
|
    ':' add_expr { $$ = $2; }
;

sub_expr:
    %empty { $$.type = NONE; }
|
    add_expr { $$ = $1; }
;

atom_expr:
    atom
    {
    		$$ = $1;
    		if($1.type == ID)
    		{
    				int i = LookUp($1.idname);
    				Sym[i].reval+=1;
    		}
    } |
    atom_expr  '[' sub_expr  ':' sub_expr  slice_op ']' {
        Val *val_list;
        int startIndex;
        int endIndex;
        $$.symnum = CreateSym($1.idname);
        switch ($1.type) {
        case ID:
            val_list = &(Sym[$$.symnum].id_value);
            break;
        case LIST:
            val_list = &$1;
            break;
        default:
            cerr << "ERROR: Try to get slice of a non-list value!, type ="
                 << val_list->type << endl;
            exit(1);
            break;
        }
        CountLength(val_list->listval);
        $$.type = LIST;
        $$.listval = new List;
        if (val_list->type != LIST) {
            cerr << "ERROR : Try to get slice of a non-list value!, type ="
                 << val_list->type << endl;
            exit(1);
        }
        if ($6.type == NONE) {
            $6.ival = 1;
        } else if ($6.type != INT || $6.ival == 0) {
            cerr << "ERROR : Invalid slice_op value!" << endl;
            exit(1);
        }
        if ($3.type == NONE) {
            $3.ival = $6.ival > 0 ? 0 : val_list->listval->length - 1;
        } else if ($3.type == INT) {
            if ($3.ival > val_list->listval->length) {
                $3.ival = val_list->listval->length;
            } else if ($3.ival < 0) {
                $3.ival += val_list->listval->length;
            }
        } else {
            cout << "$3: "<< $3.type<<","<<$3.ival<< endl;
        }
        if ($5.type == NONE) {
            $5.ival = $6.ival > 0 ? val_list->listval->length : -1;
        } else if ($5.type == INT) {
            if ($5.ival > val_list->listval->length) {
                $5.ival = val_list->listval->length;
            } else if ($5.ival < 0) {
                $5.ival += val_list->listval->length;
            }
        } else {
            cout << "$5: "<< $5.type<<","<<$5.ival<< endl;
        }
        $$.step = $6.ival;
        $$.low[0] = startIndex = $3.ival;
        $$.high[0] = endIndex = $5.ival;
        while (($6.ival > 0) ? (startIndex < endIndex) :
                            (startIndex > endIndex)) {
            $$.listval->add_to_list(val_list->listval->value(startIndex));
            startIndex += $6.ival;
        }
        $$.addrtype = LISTSLICE;
    }
|
    atom_expr  '[' add_expr ']'
    {
        if($3.type == INT)
        {
            char *a;
            int i = 0,num;
            ListNode *p;
            switch($1.type)
            {
                case STRING_LITERAL:
                    if($3.ival < 0)
                        $3.ival += strlen($1.strval);
                    if($3.ival >= strlen($1.strval))
                    {
                        yyerror("ERROR : Invalid index number!");
                        YYERROR;
                    }
                    $$.type = STRING_LITERAL;
                    $$.strval = (char*)malloc(sizeof(char)*2);
                    $$.strval[0] = $1.strval[$3.ival];
                    $$.strval[1] = '\0';
                    break;

                case LIST:
                    if($3.ival < 0)
                        $3.ival += $1.listval->length;
                    if($3.ival >= CountLength($1.listval))
                    {
                        yyerror("ERROR : Invalid index number!");
                        YYERROR;
                    }
                    $$.listval = (List*)malloc(sizeof(List));
                    if($1.listval->head != NULL)
                    {
                        p = $1.listval->head;
                        while(i < $3.ival)
                        {
                            i++;
                            p = p->next;
                        }
                        $$ = p->nodeval;


                        		$$.addrtype = LISTITEM;
                        		$$.symnum = $1.symnum;
                        		if(Sym[i].reval <= 1 )
                        		{
                        				Sym[num].id_value.low[Sym[num].id_value.depth] = $3.ival;
                            		Sym[num].id_value.depth++;
                        		}
                    }
                    break;
                case ID:
                    num = CreateSym($1.idname);
                    if(num != 0)
                    {
                        switch(Sym[num].id_value.type)
                        {
                            case STRING_LITERAL:
                                if($3.ival < 0)
                                    $3.ival +=strlen(Sym[num].id_value.strval);
                                if($3.ival >= strlen(Sym[num].id_value.strval))
                                {
                                    yyerror("ERROR : Invalid index number!");
                                    YYERROR;
                                }
                                $$.type = STRING_LITERAL;
                                $$.strval = (char*)malloc(sizeof(char)*2);
                                $$.strval[0] = Sym[num].id_value.strval[$3.ival];
                                $$.strval[1] = '\0';
                                break;

                            case LIST:
                                if($3.ival < 0)
                                    $3.ival += Sym[num].id_value.listval->length;
                                if($3.ival >= Sym[num].id_value.listval->length)
                                {
                                    yyerror("ERROR : Invalid index number!");
                                    YYERROR;
                                }
                                p = Sym[num].id_value.listval->head;
                                while(i < $3.ival)
                                {
                                    i++;
                                    p = p->next;
                                }
                                $$ = p->nodeval;
                                $$.addrtype = LISTITEM;
                                $$.symnum = num;
                                if(Sym[num].reval <= 1)
                                {
                                		Sym[num].id_value.depth=0;
                                		Sym[num].id_value.low[Sym[num].id_value.depth] = $3.ival;
                                		Sym[num].id_value.depth++;
                                }

                        }
                    }
                    break;
            }
        }
        else
        {
            //todo
        }
    }|
    atom_expr  '.' ID
    {
        $$.addrtype = $1.addrtype;
        $$.attributename = $3.idname;
        if($1.type == ID)
        		$$.idname = $1.idname;
       	else if($1.type == LIST)
       	{


       					$$.idname = Sym[$1.symnum].id_name;

       	}
    }|
    atom_expr  '(' arglist opt_comma ')'
    {
        if(strcmp($1.idname,"print") == 0)
        {
            Print($3.listval->head->nodeval);
            $$.type = NONE;
        }
        else if(strcmp($1.idname,"len") == 0)
        {
            if($3.listval->head->nodeval.type == LIST)
                printf("%d\n",CountLength($3.listval->head->nodeval.listval));
            else if($3.listval->head->nodeval.type == STRING_LITERAL)
                printf("%d\n",(int)strlen($3.listval->head->nodeval.strval));
            else if($3.listval->head->nodeval.type == ID)
            {
                int num = CreateSym($3.listval->head->nodeval.idname);
                if(Sym[num].id_value.type == LIST)
                    printf("%d\n",Sym[num].id_value.listval->length);
                else if(Sym[num].id_value.type == STRING_LITERAL)
                    printf("%d\n",(int)strlen(Sym[num].id_value.strval));
            }
            else
            {
                yyerror("ERROR : Object type has no len");
                YYERROR;
            }
            $$.type = NONE;
        }
        else if(strcmp($1.idname,"range") == 0)
        {
            if($3.listval->length > 3)
            {
                yyerror("ERROR : More arguments accepted, range() needs 3");
                YYERROR;
            }
            int start,stop,step,temp;
            if($3.listval->length < 3)
                step = 1;
            else if($3.listval->length == 3)
                step = $3.listval->head->next->next->nodeval.ival;
            ListNode *p = $3.listval->head;
            if($3.listval->length > 1)
            {
                start = $3.listval->head->nodeval.ival;
                stop = $3.listval->head->next->nodeval.ival;
            }
            else
            {
                start = 0;
                stop = $3.listval->head->nodeval.ival;
            }
            $$.type = LIST;
            Val a;
            a.type = INT;
            a.ival = start;
            $$.listval = (List*)malloc(sizeof(List));
            $$.listval->head = (ListNode*)malloc(sizeof(ListNode));
            $$.listval->head->nodeval.ival = start;
            $$.listval->head->nodeval.type = INT;
            $$.listval->tail = $$.listval->head;
            $$.listval->length = 1;
            $$.listval->head->next = NULL;
            if(start < stop && step > 0)
            {
                a.ival = start + step;
                while(a.ival<stop)
                {
                    $$.listval = AddToList(&$$,&a);
                    a.ival += step;
                }
            }

            else if(start > stop && step < 0)
            {
                a.ival = start + step;
                while(a.ival>stop)
                {
                    $$.listval = AddToList(&$$,&a);
                    a.ival += step;
                }
            }
        }
        else if(strcmp($1.idname, "list") == 0)
        {
            $$.type = LIST;
            $$.listval = $3.listval;
        }
        else if(strcmp($1.attributename, "append") == 0)
        {
            int num = CreateSym($1.idname);
            if($1.addrtype!=LISTSLICE)
            {
//                int num = CreateSym($1.idname);
                if(Sym[num].id_value.type != LIST)
                {
                     yyerror("ERROR : Object has no attribure append");
                    YYERROR;
                }
                if(Sym[num].id_value.depth == 0)
                {
            		if($3.listval->head->nodeval.type == LIST)
            		{
            				Val t;
            				t=$3.listval->head->nodeval;
            				t.listval = CopyList($3.listval->head->nodeval.listval);
            				Sym[num].id_value.listval =  AddToList(&Sym[num].id_value,&(t));
            		}
            		else
            				Sym[num].id_value.listval =  AddToList(&Sym[num].id_value,&($3.listval->head->nodeval));
                }
                else
                {
            		int cnt = Sym[num].id_value.depth;
            		int i,j,temp;
            		j=0;
            		ListNode *p = (ListNode *)malloc(sizeof(ListNode));
								p = Sym[num].id_value.listval->head;
								ListNode *tmplist=(ListNode*)malloc(sizeof(ListNode));
            		while(j <= cnt)
            		{
            				if(Sym[num].id_value.low[j]>=0)
                				temp = Sym[num].id_value.low[j];
            				else
                				temp = Sym[num].id_value.listval->length + Sym[num].id_value.low[j];
										i=0;
            				while(i<temp)
           		 			{
           		 	   			i++;
                				p = p->next;

            				}
            				j++;
            				if(j==cnt)	break;
            				else
            				{
            						if(p->nodeval.type == LIST )
            						{
            								p = p->nodeval.listval->head;
            						}
            				}
            		}
            		if($3.listval->head->nodeval.type == LIST)
            		{
            				Val t1;
            				t1=$3.listval->head->nodeval;
            				t1.listval = CopyList($3.listval->head->nodeval.listval);
            				tmplist->nodeval = t1;
            				tmplist->next = NULL;
            				p->nodeval.listval->tail->next = tmplist;
            				p->nodeval.listval->tail = tmplist;
            		}
            		else
            		{
            				tmplist->nodeval = $3.listval->head->nodeval;
            				tmplist->next = NULL;
            				p->nodeval.listval->tail->next = tmplist;
            				p->nodeval.listval->tail = tmplist;
            		}
                }
                $$.type = NONE;
                $$.symnum = num;
            }
            else
                $$.type = NONE;
                $$.symnum = num;

        }
        else
        {
            yyerror("ERROR : Not defined");
            YYERROR;
        }

    } |
    atom_expr  '('  ')'
    {
        if(strcmp($1.idname, "quit") == 0)  
        exit(0);
    }
;

arglist:
    add_expr
    {
        $$.type = LIST;
        $$.listval = (List*)malloc(sizeof(List));
        $$.listval->head = (ListNode*)malloc(sizeof(ListNode));
        $$.listval->head = (ListNode*)malloc(sizeof(ListNode));
        $$.listval->head->nodeval.type = $1.type;
        switch($1.type)
        {
            case INT:
                $$.listval->head->nodeval.ival = $1.ival;
                break;
            case REAL:
                $$.listval->head->nodeval.fval = $1.fval;
                break;
            case STRING_LITERAL:
                $$.listval->head->nodeval.strval = (char*)malloc(sizeof(char*) * (strlen($1.strval)+1));
                strncpy($$.listval->head->nodeval.strval, $1.strval, strlen($1.strval)+1);
                break;
            case LIST:
                $$.listval->head->nodeval.listval = $1.listval;
    			break;

        }
        $$.listval->tail = $$.listval->head;
        $$.listval->length = 1;//一个元素只有一
        $$.listval->head->next = NULL;
    }|
    arglist ',' add_expr
    {
        $$.type = LIST;
        $$.listval = AddToList(&$1,&$3);
    }
;

List:
    '[' ']'
    {
        $$.type = LIST;
        $$.listval = (List*)malloc(sizeof(List));
        $$.listval->head = NULL;
        $$.listval->tail = NULL;
        $$.listval->length = 0;//记录长度
    }|
    '[' List_items opt_comma ']'
    {
        $$.type = LIST;
        $$ = $2;
    }
;

opt_comma:
    %empty { $$.type = NONE; }
|
    ','
;

List_items:
    add_expr
    {
        $$.type = LIST;
        $$.listval = (List*)malloc(sizeof(List));
        $$.listval->head = (ListNode*)malloc(sizeof(ListNode));
        $$.listval->tail = (ListNode*)malloc(sizeof(ListNode));
        $$.listval->head->nodeval.type = $1.type;
        switch($1.type)
        {
            case INT:
                $$.listval->head->nodeval.ival = $1.ival;
                break;
            case REAL:
                $$.listval->head->nodeval.fval = $1.fval;
                break;
            case STRING_LITERAL:
                $$.listval->head->nodeval.strval = (char*)malloc(sizeof(char*) * (strlen($1.strval)+1));
                strncpy($$.listval->head->nodeval.strval, $1.strval, strlen($1.strval)+1);
                break;
            case LIST:
                $$.listval->head->nodeval.listval = $1.listval;
    			break;

        }
        $$.listval->tail = $$.listval->head;
        $$.listval->length = 1;//一个元素只有一
        $$.listval->head->next = NULL;
    }|
    List_items ',' add_expr
    {
        $$.type = LIST;
        $$.listval = AddToList(&$1,&$3);
    }
;

add_expr:
    add_expr '+' mul_expr
    {
        int length1,length2;
        List* a;
        switch($1.type)
        {
            case INT:
                switch($3.type)
                {
                    case INT:
                        $$.type = INT;
                        $$.ival = $1.ival + $3.ival;
                        break;
                    case REAL:
                        $$.type = REAL;
                        $$.fval = (float)$1.ival + $3.fval;
                        break;
                    default:
                        /*-------------------------------------------*/
                        yyerror("ERROR : invalid '+' operation for int!");
                        YYERROR;
                        break;
                }
                break;
            case REAL:
                switch($3.type)
                {
                    case INT:
                        $$.type = REAL;
                        $$.fval = $1.fval + $3.ival;
                        break;
                    case REAL:
                        $$.type = REAL;
                        $$.fval = $1.fval + $3.fval;
                        break;
                    default:
                        printf("%d %d",REAL,$3.type);
                        /*-------------------------------------------*/
                        yyerror("ERROR : invalid '+' operation for real!");
                        YYERROR;
                        break;
                }
                break;
            case STRING_LITERAL:
                switch($3.type)
                {
                    case STRING_LITERAL:
                        $$.type = STRING_LITERAL;
                        length1 = strlen($1.strval);
                        length2 = strlen($3.strval);
                        $$.strval = (char*)malloc(sizeof(char) * (length1 + length2 + 2));
                        strncpy($$.strval, $1.strval, length1+1);
                        strcat($$.strval, $3.strval);
                        break;
                    default:
                        /*-------------------------------------------*/
                        yyerror("ERROR : invalid '+' operation for string!");
                        YYERROR;
                        break;
                }
                break;
            case LIST:
                $$.type = LIST;
                a = CopyList($1.listval);
                if($1.listval->head == NULL)
                    $$.listval = $3.listval;
                if($3.type == LIST)
                {
                    if($1.listval->head == NULL)
                        $$.listval = $3.listval;
                    else
                    {
                        a->tail->next = $3.listval->head;
                        a->tail = $3.listval->tail;
                        a->length = a->length + $3.listval->length;//总长度等于两者之和
                        $$.listval = a;
                    }
                }
                else
                {
                    /*-------------------------------------------*/
                    yyerror("ERROR : invalid '+' operation for list!");
                    YYERROR;
                }
                break;
            default:
                break;
        }
    }|
    add_expr '-' mul_expr
    {
        switch($1.type)
        {
            case INT:
                switch($3.type)
                {
                    case INT:
                        $$.type = INT;
                        $$.ival = $1.ival - $3.ival;
                        break;
                    case REAL:
                        $$.type = REAL;
                        $$.fval = $1.ival - $3.fval;
                        break;
                    case LIST:
                        /*-------------------------------------------*/
                        yyerror("ERROR : invalid '-' operation for int!");
                        YYERROR;
                        break;
                }
                break;
            case REAL:
                switch($3.type)
                {
                    case INT:
                        $$.type = REAL;
                        $$.fval = $1.fval - $3.ival;
                        break;
                    case REAL:
                        $$.type = REAL;
                        $$.fval = $1.fval - $3.fval;
                        break;
                    case LIST:
                        /*-------------------------------------------*/
                        yyerror("ERROR : invalid '-' operation for real!");
                        YYERROR;
                        break;
                }
                break;
            case STRING_LITERAL:
                /*-------------------------------------------*/
                yyerror("ERROR : invalid '-' operation for string!");
                YYERROR;
                break;
            case LIST:
                /*-------------------------------------------*/
                yyerror("ERROR : invalid '-' operation for list!");
                YYERROR;
                break;
        }
    }|
    mul_expr
;

mul_expr:
    mul_expr '*' mul_expr
    {
        List *a;
        switch($1.type)
        {
            case INT:
                switch($3.type)
                {
                    case INT:
                        $$.type = INT;
                        $$.ival = $1.ival * $3.ival;
                        break;
                    case REAL:
                        $$.type = REAL;
                        $$.fval = (float)$1.ival * $3.fval;
                        break;
                    case LIST:
                        $$.type = LIST;
                        if($3.listval->head == NULL)
                            $$.listval = $3.listval;
                        else
                        {
                            a = CopyList($3.listval);
                            $$.listval = MulList(a, $1.ival);
                            $$.listval->length = CountLength(a);//维护长度
                        }
                        break;
                    case STRING_LITERAL:
                        $$.type = STRING_LITERAL;
                        int length1 = strlen($3.strval);
                        $$.strval = (char*)malloc(sizeof(char) * (length1 + 1) * $1.ival);
                        strncpy($$.strval, $3.strval, length1+1);
                        for(int i = 1;i < $1.ival;i++)
                        {
                            strcat($$.strval, $3.strval);
                        }
                        break;
                }
                break;
            case REAL:
                switch($3.type)
                {
                    case INT:
                        $$.type = REAL;
                        $$.fval = $1.fval * $3.ival;
                        break;
                    case REAL:
                        $$.type = REAL;
                        $$.fval = $1.fval * $3.fval;
                        break;
                    default:
                        /*-------------------------------------------*/
                        yyerror("ERROR : invalid '*' operation for real!");
                        YYERROR;
                        break;
                }
                break;
            case STRING_LITERAL:
                if($3.type == INT)
                    {
                        $$.type = STRING_LITERAL;
                        int length1 = strlen($1.strval);
                        $$.strval = (char*)malloc(sizeof(char) * (length1 + 1) * $3.ival);
                        strncpy($$.strval, $1.strval, length1+1);
                        for(int i = 1;i < $3.ival;i++)
                        {
                            strcat($$.strval, $1.strval);
                        }
                    }
                else
                {
                    /*-------------------------------------------*/
                    yyerror("ERROR : invalid '*' operation for string!");
                    YYERROR;
                }
                break;
            case LIST:
                if($3.type == INT)
                {
                    $$.type = LIST;
                    if($1.listval->head == NULL)
                        $$.listval = $1.listval;
                    else
                    {
                        a = CopyList($1.listval);
                        $$.listval = MulList(a, $3.ival);
                        $$.listval->length = CountLength(a);//维护长度
                    }
                }
                else
                {
                    /*-------------------------------------------*/
                    yyerror("ERROR : invalid '*' operation for list!");
                    YYERROR;
                }
                break;
            default:
                break;
        }
    }|
    mul_expr '/' mul_expr
    {
        $$.type = REAL;
        if($1.type == INT)
            $1.fval = (float)$1.ival;
        if($3.type == INT)
            $3.fval = (float)$3.ival;
        if($3.fval < 10e-10)
            yyerror("ERROR : Divided by zero!");
            YYERROR;
        $$.fval = $1.fval / $3.fval;
        if($1.type == STRING_LITERAL || $3.type == STRING_LITERAL || $1.type == LIST || $3.type == LIST)
        {
            /*-------------------------------------------*/
            yyerror("ERROR : unspported operand types for /!");
            YYERROR;
        }
    }|
    mul_expr '%' mul_expr
    {
        if(($1.type == INT) && ($3.type == INT))
        {
            $$.type = INT;
            $$.ival = $1.ival % $3.ival;
            if($$.ival < 0)
                $$.ival += $3.ival;
        }
        else
        {
            $$.type = REAL;
            if($1.type == REAL)
            $1.fval = (float)$1.ival;
            if($3.type == REAL)
            $3.fval = (float)$3.ival;
            int temp = (int)($3.fval / $3.fval);
            $$.fval = $1.fval - ($3.fval * temp);
            if($1.fval * $3.fval < 0)
            $$.fval += $3.fval;
        }
        if($1.type == STRING_LITERAL || $3.type == STRING_LITERAL || $1.type == LIST || $3.type == LIST)
        {
            /*-------------------------------------------*/
            yyerror("ERROR : unspported operand types for %!");
            YYERROR;
        }
    }|
    '(' add_expr ')'
    {
                $$ = $2;
    }|
    '(' mul_expr ')'
    {
                $$ = $2;
    }|
    factor
    {
        $$ = $1;
    }
;

%%

int main()
{
    int i,j;
    for(i = 0;i < 101;i++)
    {
        Sym[i].id_name = NULL;
        for(j = 0;j<10;j++)
            Sym[i].id_value.high[j] = 0;
            Sym[i].id_value.low[j] = 0;
        Sym[i].id_value.depth = 0;
    }
	return yyparse();
}

void yyerror(char *s)
{
	cout << s << endl << "miniPy> ";

}

int yywrap()
{
	return 1;
}

// Class Defination

/*** class Val ***/
Val::Val() {
    type = UNKNOWN_TYPE;
    addrtype = UNKNOWN_TYPE;
    symnum = 0;
    attributename = nullptr;
    idname = nullptr;
}

void Val::deep_copy (const Val &assign_val){
    type = assign_val.type;
    addrtype = assign_val.addrtype;
    symnum = assign_val.symnum;
    attributename = assign_val.attributename;
    fval = assign_val.fval;
    // Deep Copy
    switch (type) {
    case ID:
        // NEED DUBUG
        idname = new char[strlen(assign_val.idname)+1];
        memcpy(idname,
            assign_val.idname, strlen(assign_val.idname)+1);
        break;
    case STRING_LITERAL:
        // NEED DUBUG
        strval = new char[strlen(assign_val.strval)+1];
        memcpy(strval,
            assign_val.strval, strlen(assign_val.strval)+1);
        break;
    case LIST:
        listval = new List;
        ListNode *copy_node;
        copy_node = assign_val.listval->head;
        while (copy_node != nullptr) {
            listval->add_to_list(&copy_node->nodeval);
            copy_node = copy_node->next;
        }
        break;
    default:
        break;
    }
    return;
}

Val::~Val() {
/** by WntFlm
 *  TODO: Is it needed to free idname and strval? And how.
 */
    switch (type) {
    case ID:
        // delete idname;
        break;
    case STRING_LITERAL:
        // delete strval;
        break;
    }
}

/*** class List ***/
List::List() {
    head = tail = nullptr;
    length = 0;
}

List *List::add_to_list(Val *add_val) {
// Assert acc_val is not a list-type value
    ListNode *new_node = new ListNode;
    new_node->nodeval.deep_copy(*add_val);
    new_node->next = nullptr;
    if (length == 0) {
        head = tail = new_node;
    } else {
        tail->next = new_node;
        tail = new_node;
    }
    length++;
    return this;
}

void List::delete_node(int index) {
    if (index == 0) {
       head = head -> next;
    }
    ListNode *ptr = head;
    for(int i = 0; i < index - 1; i++){
        if (ptr->next == nullptr) {
            yyerror("ERROR: Find nullptr when List::delete_node");
            return;
        } else {
            ptr = ptr->next;
        }
    }
    if (ptr->next == tail) {
        tail = ptr;
    }
    ptr->next = ptr->next->next;
    // without freeing del_node
    return;
}

void List::insert(int index, Val *insert_val) {
    ListNode *new_node = new ListNode;
    new_node->nodeval.deep_copy(*insert_val);
    CountLength(this);
    if (index > length) {
        yyerror("ERROR: Array index out of range!");
    }
    if (index == 0) {
        new_node->next = head;
        head = new_node;
    } else {
        ListNode *ptr = head;
        for(int i = 0; i < index - 1; i++){
            if (ptr == nullptr) {
                yyerror("ERROR: Find nullptr when List::delete_node");
                return;
            } else {
                ptr = ptr->next;
            }
        }
        new_node->next = ptr->next;
        ptr->next = new_node;
    }
    if (index == length) {
        tail = new_node;
    }
    length++;
    return;
}

Val *List::value(const int index) {
    ListNode *ptr = head;
    for(int i = 0; i < index; i++){
        if (ptr->next == nullptr) {
            yyerror("ERROR: Find nullptr when List::GetNode");
            return nullptr;
        } else {
            ptr = ptr->next;
        }
    }
    return &(ptr->nodeval);
}

List::~List() {
    delete head;
}

/*** class ListNode ***/
ListNode::~ListNode() {
    ListNode *ptr = this;
    ListNode *next = nullptr;
    while (ptr != nullptr) {
        next = ptr->next;
        delete ptr;
        ptr = next;
    }
}
