module exskeleton;

    //import std.c.time;
    import std.stdio;
    import std.concurrency;
    import core.time;
    import std.algorithm;
    import std.random;

    struct CancelMessage{}



    struct Noeud
    {
        Tid tid; //thread_ID
        int lid; //logical_ID
        int previousId;
        int nextId;
        int leader;

        
        
    }

    
    

    void receiveAllFinalization(Noeud [] childTid)
    {
        for(int i=0 ; i<childTid.length ; ++i)
            receiveOnly!CancelMessage();
    }

    void spawnedFunc(int myId, int n)
    {
        

        // Noeud voisin suivant et precedent 
        Noeud neighbor, localNeighbor,localPrevious;

        // Fils droit et fils gauche 
        Noeud fg,fd;




        


        
    


        
        
        
        
        
        // waiting for the reception of information sent by the father


        
        receive
        (
        (immutable(Noeud) neighbor,immutable(Noeud) previous)
            {
            
                localNeighbor = cast(Noeud)neighbor;
                localPrevious = cast(Noeud)previous;




            }
        );


        

        /* Arbre binaire */
        receive
        (
            
            (immutable(Noeud) filsg, immutable(Noeud)filsd,int i,int taille)
            {

                /* cas spécifique pour une taille de l'arbre n < 4 */

                if(taille == 1){
                    writeln("[Son process ",myId,"]: Je suis une feuille") ;
                }

                else if(taille == 2){
                    if(i == 0){
                        fg = cast(Noeud)filsg;
                        writeln("[Son process ",myId,"]: Fils gauche ",fg.lid);
                    }
                    else{
                        writeln("[Son process ",myId,"]: Je suis une feuille");

                    }

                }

                else if(taille == 3){
                    if(i == 0){
                        fg = cast(Noeud)filsg;
                        fd = cast(Noeud)filsd;
                        writeln("[Son process ",myId,"]: Fils gauche ",fg.lid," et fils droit ",fd.lid);
                    }
                    else{
                        writeln("[Son process ",myId,"]: Je suis une feuille");

                    }

                }
                
                
                /* si la taille de l'arbre est paire */
                else if(taille % 2 == 0){

                    if(i == (n/2)-1){
                        fg = cast(Noeud)filsg;
                        writeln("[Son process ",myId,"]: Fils gauche ",fg.lid);
                        
                    } 
                    else if(i < (taille/2)) {
                        fg = cast(Noeud)filsg;
                        fd = cast(Noeud)filsd;
                        writeln("[Son process ",myId,"]: Fils gauche ",fg.lid," et fils droit ",fd.lid);
                    }
                    else{
                        writeln("[Son process ",myId,"]: Je suis une feuille");


                    }
                    
                }

                /* si la taille de l'arbre est impaire */
                else if(taille % 2 == 1){
                    if(i < (n/2)){
                        fg = cast(Noeud)filsg;
                        fd = cast(Noeud)filsd;
                        writeln("[Son process ",myId,"]: Fils gauche ",fg.lid," et fils droit ",fd.lid);
                    }
                    else{
                        writeln("[Son process ",myId,"]: Je suis une feuille");

                    }

                    

                }
                
                
            }
        );

        
        
   





       
       

       /* Anneau bidirectionnel  */


        send(localNeighbor.tid,myId);
        receive
        (
        (int idVoisin)
            {
                
                localNeighbor.previousId = myId;
                localPrevious.nextId = myId;
                /* résumé */
                writeln("[Son Process ",myId,"]: ",localPrevious.lid," est l'ID du voisin precedent et ",localNeighbor.lid," est l'ID du voisin suivant");
                
                
            }
        );
        


         // CHANG ROBERT ALGO
        bool leaderconnu = false;
        int leader = myId;
        int msg = 1;
        send(localNeighbor.tid, leader ,false);
        while(leaderconnu == false)
        {
            // writeln(myId," en attente.");
            receive(
                (int j,bool b){

                /* si l'id est la même alors le candidat est trouvé */
                if (j == myId){ 
                
                    leader = myId;
                    msg += 1;
                    send(localNeighbor.tid, leader,true);

            }
            /* si l'id recu est plus grand que l'id candidat */
            else if (j > myId){
                /* on change de leader */
                leader = j;
                msg += 1;
                send(localNeighbor.tid,leader, b);
            }
            leaderconnu = b;
    

                    
                        
                }
        );
        }
        writeln("[SonProcess ",myId,"]: Le leader final est ",leader," et le nombre de messages est ",msg);


        





        

        // ALGO RENUMEROTATION 

        if(myId == 0){

            /* Noeud initiateur pour connaitre la taille et la renumérotation une  */

            int size = 1;
            
            int newId = 0;

            /* Envoie du premier message pour connaitre la taille de l'anneau */

            writeln("\r\n\r\n[Son process init ",myId,"]: initialisation pour connaitre la taille de l'anneau...\r\n");
            send(localNeighbor.tid,size);
            receive((int tailleConnu){
                writeln("\r\n[Son process init ",myId,"]: La taille de l'anneau est ",tailleConnu,". Renumérotation en cours...\r\n");


                int cpt;
                
                int [] next = new int[tailleConnu];

                
                /+
                /* génération d'un tableau de random d'entier de taille tailleConnu */
                auto rnd = Random(unpredictableSeed);
                for(int i = 0; i < n; ++i) 
                {
                    next[i]=i%n;
                }

                /* le do while n'est pas nécéssaire pour la génération random de nombre dans le tableau mais j'avais un probleme dans le main que je n'avais pas encore corrigé */
                do {
                    cpt = 0;
                    next.randomShuffle(rnd);
                    for(int i = 0 ;i < n ; i ++){
                        if (next[i] == i){
                            cpt += 1;
                        }
                    }

                }while(cpt > 0);

                //localNeighbor.lid = next[cpt];
                +/
                
                    

               
                /* Debut renumérotation avec l'attribution du premier ID = 0 au voisin */
                
                

                localNeighbor.lid = newId;


                size = tailleConnu - 1;

                
                send(localNeighbor.tid, newId, tailleConnu);
            });
        }

        if(myId != 0){

            /* Chaque noeud non initiateur recoit la taille et l'incrémente avant de l'envoyer à son voisin */

            receive((int taille){
                taille += 1;
                writeln("[Son process ",myId,"]: La taille est maintenant de ",taille);
                send(localNeighbor.tid,taille);

            });
        }


        receive((int newId ,int  taille){ 
            /* Changement des ID en restant cohérent avec la structure du noeud voisin */
            if(newId == taille - 1){
                myId = newId;
                localNeighbor.lid = 0;
                writeln("[Son process init ",myId,"]: Le voisin suivant a l'ID ",localNeighbor.lid,"\r\n");
                writeln("[Son process init ",myId,"]: Fin du processus de renumérotation.");

            }
            else{

                newId += 1;
                if( newId < taille ){    
                    myId = newId - 1 ;
                    localNeighbor.lid = newId;
                    writeln("[Son process ",myId,"]: Le voisin suivant a l'ID ",localNeighbor.lid);
                // writeln("[Son process ",myId,"]: nouveau ID attribué au voisin ",cpt);
                }
            }
            send(localNeighbor.tid, newId, taille);
                    


        });



    










       
        /* CHANG ROBERT */

        /* initialisation */

    /*
        bool leaderconnu = false;
        int leader = myId;

        send(localNeighbor.tid, leader ,false);
        
        
        
        while(leaderconnu == false)
        {
            // writeln(myId," en attente.");
            receive(
                (int j,bool candidat){
                    if (candidat == false){
                        if(leader > j ){
                            leader = myId;
                            //writeln("Process ",myId,": conservation leader ",leader);
                            send(localNeighbor.tid,leader,false);
                        }
                        if(j > leader){
                            leader = j ;
                            //writeln("Process ",myId,": nouveau leader ",leader);
                            send(localNeighbor.tid,leader,false);
                        }
                        else{
                            leaderconnu = true;
                            //writeln("Process ",myId,": le leader est ",leader);
                            send(localNeighbor.tid,leader,true);
                        }
                    }
                    else{
                        
                        leaderconnu  = true;
                        send(localNeighbor.tid,leader,true);  
                    }
    

                    
                        
                }
        );
        }

        writeln("Process ",myId,": le leader final est ",leader);
    
    */

    


    /+ TRUE CODE
        bool leaderconnu = false;
        int leader = myId;
        int msg = 1;
        send(localNeighbor.tid, leader ,false);
        
        
    while(leader != n){
        while(leaderconnu == false)
        {
            // writeln(myId," en attente.");
            receive(
                (int j,bool b){

                /* si l'id est la même alors le candidat est trouvé */
                if (j == myId){ 
                
                    leader = myId;
                    msg += 1;
                    send(localNeighbor.tid, leader,true);

            }
            /* si l'id recu est plus grand que l'id candidat */
            else if (j > myId){
                /* on change de leader */
                leader = j;
                msg += 1;
                send(localNeighbor.tid,leader, b);
            }
            leaderconnu = b;
    

                    
                        
                }
        );
        }

    }

        writeln("[SonProcess ",myId,"]: Le leader final est ",leader," et le nombre de messages est :",msg);


    +/
    





        // end of your code

        send(ownerTid, CancelMessage());
        
    }


    void main()
    {
        // number of child processes
        int n = 10;

        int cpt ;
        int [] next = new int[n];

        /* générer un tableau de random ID */

        
        auto rnd = Random(unpredictableSeed);
        
        /*
        for(int i = 0; i < n; ++i) 
        {
            next[i]=i%n;
        }
        */

        
for(int i = 0; i < n; ++i) 
    {
    next[i]=i;
    }

   next.randomShuffle(rnd);
   writeln(next);

        
        

        
       


        // spawn threads (child processes)
        Noeud [] childTid = new Noeud[n];

        for(int i = 0; i < n; ++i)
        {
            childTid[i].tid = spawn(&spawnedFunc, next[i], n);
            childTid[i].lid = next[i];
            
        }






        
       
        // anneau bidirectionnel
        for(int i = 0; i < n; ++i)
        {
         

            if(i == n -1){
                immutable(Noeud) id_suiv = cast(immutable)childTid[0];
                immutable(Noeud) id_prec = cast(immutable)childTid[i-1];
                send(childTid[i].tid, id_suiv,id_prec);  

            }

            else if (i == 0){
                immutable(Noeud) id_suiv = cast(immutable)childTid[i+1];
                immutable(Noeud) id_prec = cast(immutable)childTid[n-1];
                send(childTid[i].tid, id_suiv,id_prec); 

            }

            else {

                immutable(Noeud) id_suiv = cast(immutable)childTid[i+1];
                immutable(Noeud) id_prec = cast(immutable)childTid[i-1];
                send(childTid[i].tid, id_suiv,id_prec);  
            }
        
              
        }


        

        // create binary tree
        

        // cas spécifique si la taille de l'arbre binaire est inférieure a 4

        if(n < 4){
            // arbre de taille 1
            if (n == 1){
                immutable(Noeud) fd ;
                immutable(Noeud) fg ;
                send(childTid[0].tid, fg,fd,0,n);

            }
            // arbre de taille 2
            else if(n == 2){
                for(int i = 0; i < n ;i++){
                    if(i == 0){
                        /* que un fils gauche */
                        immutable(Noeud) fg = cast(immutable)childTid[1];
                        immutable(Noeud) fd ;
                        send(childTid[i].tid, fg,fd,i,n);
                    }
                    else{
                        /* une feuille */
                        immutable(Noeud) fd ;
                        immutable(Noeud) fg ;
                        send(childTid[i].tid, fg,fd,i,n);

                    }
                }
            }
            
            // arbre de taille 3

            else if(n == 3){
                for(int i = 0 ; i < n ; i++){
                    if(i== 0){
                        immutable(Noeud) fg = cast(immutable)childTid[1];
                        immutable(Noeud) fd = cast(immutable)childTid[2];
                        send(childTid[i].tid, fg,fd,i,n);
                    }
                    else{
                        /* une feuille */
                        immutable(Noeud) fg ;
                        immutable(Noeud) fd ;
                        send(childTid[i].tid, fg,fd,i,n);
                        
                    }
                }
            }
        }


        /* si un arbre binaire avec un nb de noeud impaire */
        else if(n  % 2  == 1){
            writeln("Création d'un arbre binaire de taille impaire:  ",n);

        
            for (int i = 0; i < n ;i ++){
                
                if(i < n/ 2){
                    if (i == 0){
                        immutable(Noeud) fg = cast(immutable)childTid[1];
                        immutable(Noeud) fd = cast(immutable)childTid[2];
                        send(childTid[i].tid, fg,fd,i,n);  

                    }
                    else if(i == (n/2)){
                        
                        
                        if(i % 2 ==  1){
                            
                            immutable(Noeud) fg = cast(immutable)childTid[i*2+1];
                            immutable(Noeud) fd = cast(immutable)childTid[i*2+2];
                            send(childTid[i].tid, fg,fd,i,n);
                            
                        }
                    }

                    
                    else{
                        immutable(Noeud) fg = cast(immutable)childTid[i*2+1];
                        immutable(Noeud) fd = cast(immutable)childTid[i*2+2];
                        send(childTid[i].tid, fg,fd,i,n);

                    }
                }
                else{
                    /* une feuille */
                    immutable(Noeud) fd ;
                    immutable(Noeud) fg ;
                    send(childTid[i].tid, fg,fd,i,n);

                }


                

            }
            }
        
        /* Si un arbre binaire avec un nombre de noeud paire */
        else if (n % 2 == 0 ){
            writeln("Création d'un arbre binaire de taille paire:  ",n);
            for (int i = 0; i < n ;i ++){
                if( i < (n/2)){
                
                    if (i == 0){
                        immutable(Noeud) fg = cast(immutable)childTid[1];
                        immutable(Noeud) fd = cast(immutable)childTid[2];
                        send(childTid[i].tid, fg,fd,i,n);

                    }
                    else if(i == (n/2)-1){
                        /* que un fils gauche */
                        
                        immutable(Noeud) fg = cast(immutable)childTid[i*2+1];
                        immutable(Noeud) fd ;
                        send(childTid[i].tid, fg,fd,i,n);
                    }
                    
                    else{
                        immutable(Noeud) fg = cast(immutable)childTid[i*2+1];
                        immutable(Noeud) fd = cast(immutable)childTid[i*2+2];
                        send(childTid[i].tid, fg,fd,i,n);

                }
            }

            /* ceux là n'ont ni fils droit ni fils gauche mais on simule un envoie pour que le programme se deroule */
            else{
                immutable(Noeud) fd ;
                immutable(Noeud) fg ;
                send(childTid[i].tid, fg,fd,i,n);

            }

        }
        }

        

        
        
        
        
        // wait for all completions
        receiveAllFinalization(childTid);

    }