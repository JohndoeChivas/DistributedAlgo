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


        

        

     

        
        
   





       
       
        
        // Verification anneau bidirectionnel  

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





        // Vérification arbre binaire

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

            writeln("[Son process init ",myId,"]: initialisation pour connaitre la taille de l'anneau...\r\n");
            send(localNeighbor.tid,size);
            receive((int tailleConnu){
                writeln("[Son process init ",myId,"]: La taille de l'anneau est ",tailleConnu,". Renumérotation en cours...\r\n");


                int cpt;
                
                int [] next = new int[tailleConnu];

                

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




        // end of your code

        send(ownerTid, CancelMessage());
        
    }
    



    // Fonction gérant les processus fils de la grille */

    void spanwedGrid(int myId, int n){

        Noeud gauche,droite,haut,bas;


        receive
        (
        (immutable(Noeud) h,immutable(Noeud) b,immutable(Noeud) g,immutable(Noeud) d,int i,int j,int myId)
            {
            
            if(i == 0){
                /* coin frontiere haut gauche */
                if(j == 0){
                    bas = cast(Noeud)b;
                    droite = cast(Noeud)d;
                    writeln("[Son process grid ",myId,"]: 2 voisins cases: ",d.lid," et ",b.lid);
                }
                /* coin frontiere haut droite */
                else if(j == n-1){
                    gauche = cast(Noeud)g;
                    bas = cast(Noeud)b;
                    writeln("[Son process grid ",myId,"]: 2 voisins cases: ",g.lid," et ",h.lid);

                }
                /* frontiere gauche */
                else if(j < n-1){
                    haut = cast(Noeud)h;
                    bas = cast(Noeud)b;
                    droite = cast(Noeud)d;
                    writeln("[Son process grid ",myId,"]: 3 voisins cases: ",h.lid,", ",d.lid," et ",b.lid);
                }

            }
            else if (i == n-1){
                /* coin frontiere haut droite */
                if(j == 0){
                    gauche = cast(Noeud)g;
                    bas = cast(Noeud)b;
                    writeln("[Son process grid ",myId,"]: 2 voisins cases: ",g.lid," et ",b.lid);
                }
                /* coin frontiere bas droite */
                else if(j == n-1){
                    haut = cast(Noeud)h;
                    gauche = cast(Noeud)g;
                    writeln("[Son process grid ",myId,"]: 2 voisins cases: ",h.lid," et ",g.lid);

                }
                /* frontiere droite */
                else if(j < n-1){
                    haut = cast(Noeud)h;
                    gauche = cast(Noeud)g;
                    bas = cast(Noeud)b;
                    writeln("[Son process grid ",myId,"]: 3 voisins cases: ",h.lid,", ",g.lid," et ",b.lid);
                }

            }

            else if(j == 0){

                /* frontiere haut */
                if(i > 0 && i < n-1){
                    gauche = cast(Noeud)g;
                    droite = cast(Noeud)d;
                    bas = cast(Noeud)b;
                    writeln("[Son process grid ",myId,"]: 3 voisins cases: ",g.lid,", ",d.lid," et ",b.lid);
                }

            }
            else if(j == n - 1){
                
                /* frontiere bas */
                if(i > 0  && i < n -1){
                    haut = cast(Noeud)h;
                    gauche = cast(Noeud)g;
                    droite = cast(Noeud)d;
                    writeln("[Son process grid ",myId,"]: 3 voisins cases: ",h.lid,", ",g.lid," et ",d.lid);


                }
            }

            /* sinon a l'interieur de la grille */
            else{
                haut = cast(Noeud)h;
                droite = cast(Noeud)d;
                gauche = cast(Noeud)g;
                bas = cast(Noeud)b;
                writeln("[Son process grid ",myId,"]: 4 voisins cases: ",h.lid,", ",g.lid,", ",d.lid,", ",b.lid);

            }


            
                
                




            }
        );


        










    }


    void main()
    {
        // number of child processes
        int n = 10;

        int cpt ;
        int [] next = new int[n];

        /* générer un tableau de random ID */

        
        auto rnd = Random(unpredictableSeed);
        
       
        
        for(int i = 0; i < n; ++i) 
        {
            next[i]=i;
        }

        
        next.randomShuffle(rnd);
        writeln(next,"\r\n");

        
        

        
    


        // spawn threads (child processes)
        Noeud [] childTid = new Noeud[n];
        /+

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


        

        // creation arbre binaire
        

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

        +/




        

        

        // child grille processus


        //  CODE DE LA TOPOLOGIE EN GRILLE 

        
        int idGrid = 0;
        n = 4;
        auto childTidGrid = new Noeud[][](n,n);

        /* On atribue d'abord les ID pour chaque noeud de l'anneau */

        for(int i = 0; i < n; i++)
        {
            for(int j = 0 ;j <n ; j++){
                childTidGrid[i][j].tid = spawn(&spanwedGrid,idGrid,n);
                childTidGrid[i][j].lid = idGrid;
                idGrid += 1;
            }
        }
        

        /* Ensuite on envoie leurs voisins selon leur place */

        for(int i = 0 ;i < n; i++){
            for(int j = 0 ; j<n;j++){
            
                
                
        if(i == 0){

                    /* coin haut gauche de la grille 2 voisins */
            if(j == 0){

                immutable(Noeud) h ;
                immutable(Noeud) b = cast(immutable)childTidGrid[i][j+1];
                immutable(Noeud) d = cast(immutable)childTidGrid[i+1][j];
                immutable(Noeud) g ;
                send(childTidGrid[i][j].tid, h,b,g,d,i,j,childTidGrid[i][j].lid);
                
            }


            /* coin bas gauche de la grille 2 voisins */
            else if(j == n-1){

                immutable(Noeud) h = cast(immutable)childTidGrid[i][j-1];
                immutable(Noeud) b ;
                immutable(Noeud) d ;
                immutable(Noeud) g = cast(immutable)childTidGrid[i+1][j];
                send(childTidGrid[i][j].tid, h,b,g,d,i,j,childTidGrid[i][j].lid);                        
            }


            /* sinon 3 voisins */
            else{
                immutable(Noeud) h = cast(immutable)childTidGrid[i][j-1];
                immutable(Noeud) b = cast(immutable)childTidGrid[i][j+1];
                immutable(Noeud) d = cast(immutable)childTidGrid[i+1][j];
                immutable(Noeud) g ;
                send(childTidGrid[i][j].tid, h,b,g,d,i,j,childTidGrid[i][j].lid); 

            }
        }

        else if (i == n -1 ){

            /* coin haut droite de la grille 2 voisins */
            if (j == 0 ){
                immutable(Noeud) h ;
                immutable(Noeud) b = cast(immutable)childTidGrid[i][j+1];
                immutable(Noeud) d ;
                immutable(Noeud) g = cast(immutable)childTidGrid[i-1][j];
                send(childTidGrid[i][j].tid, h,b,g,d,i,j,childTidGrid[i][j].lid);
                
            }


            /* coin bas droite de la grille 2 voisins */
            else if(j == n -1){

                immutable(Noeud) h = cast(immutable)childTidGrid[i][j-1];
                immutable(Noeud) b ;
                immutable(Noeud) d;
                immutable(Noeud) g = cast(immutable)childTidGrid[i-1][j];
                send(childTidGrid[i][j].tid, h,b,g,d,i,j,childTidGrid[i][j].lid);    

            }

            /* sinon 3 voisins */
            else{
                immutable(Noeud) h = cast(immutable)childTidGrid[i][j-1];
                immutable(Noeud) b = cast(immutable)childTidGrid[i][j+1];
                immutable(Noeud) d ;
                immutable(Noeud) g = cast(immutable)childTidGrid[i-1][j];
                send(childTidGrid[i][j].tid, h,b,g,d,i,j,childTidGrid[i][j].lid);

            }

        }
                
        else if (j == 0){

            /* frontiere en haut mais pas aux extremités des lignes */
            if(i > 0 && i < n -1){
                
                immutable(Noeud) h ;
                immutable(Noeud) b = cast(immutable)childTidGrid[i][j+1];
                immutable(Noeud) d = cast(immutable)childTidGrid[i+1][j];
                immutable(Noeud) g = cast(immutable)childTidGrid[i-1][j];
                send(childTidGrid[i][j].tid, h,b,g,d,i,j,childTidGrid[i][j].lid);

            }
                                
        }
        else if(j == n-1){

            /* frontiere en bas mais pas aux extremités des lignes */
            if(i > 0 && i < n -1){
                immutable(Noeud) h = cast(immutable)childTidGrid[i][j-1];
                immutable(Noeud) b ;
                immutable(Noeud) d = cast(immutable)childTidGrid[i+1][j];
                immutable(Noeud) g = cast(immutable)childTidGrid[i-1][j];
                send(childTidGrid[i][j].tid, h,b,g,d,i,j,childTidGrid[i][j].lid);

            }
        }


                /* sinon noeud qui ne sont pas a la frontiere */
        else{

                immutable(Noeud) h = cast(immutable)childTidGrid[i][j-1];
                immutable(Noeud) b = cast(immutable)childTidGrid[i][j+1];
                immutable(Noeud) d = cast(immutable)childTidGrid[i+1][j];
                immutable(Noeud) g = cast(immutable)childTidGrid[i-1][j];
                send(childTidGrid[i][j].tid, h,b,g,d,i,j,childTidGrid[i][j].lid);
            

        }
        
            }
        }


                
                
            
            
        

       
        
        



        
        // wait for all completions
        receiveAllFinalization(childTid);

    }