
source("SKAT_ana.R")
## step 0: case control sex and family member distribution and BRCA1/2 pathogenic families
BRCAFam <- function(){
    pheno <- pheno_all()  
    ### BRCA families
    br <- c(223109,223041,223275,260333,222968) 
    
    unif <- pheno[pheno[,3] %in% br,1]
    allm <- pheno[pheno[,1] %in% unif,3]
    
    load("alllist_10_20")
    subs <- (alllist[,"Subject_ID"] %in% allm) & (alllist[,"Gene"] %in% c("BRCA1","BRCA2"))
    tmplist <- alllist[subs,]
    
    phetmp <- pheno[match(tmplist[,"Subject_ID"],pheno[,3]),]
    
    allV <- cbind(phetmp,tmplist)
    qwt(allV,file="BRCAFam.txt",flag=2)

}

Famdis <- function(){
    pheno <- pheno_all()

    ### case and control
    tmp <- table(pheno[,1])
    tmp1 <- sort(unique(tmp))
    famdis <- matrix(0,length(tmp1),4)
    teM <- matrix(0,length(tmp1),5)
    for(i in 1:length(tmp1)){
        tmpfam <- names(tmp)[tmp==tmp1[i]]
        teM[i,1] <- sum(pheno[,1] %in% tmpfam)
        teM[i,2] <- sum(pheno[,1] %in% tmpfam & pheno[,"BreastCancer"]=="Yes" & pheno[,"Sex"]=="Female")
        teM[i,3] <- sum(pheno[,1] %in% tmpfam & pheno[,"BreastCancer"]=="Yes" & pheno[,"Sex"]=="Male")
        teM[i,4] <- sum(pheno[,1] %in% tmpfam & pheno[,"BreastCancer"]=="No" & pheno[,"Sex"]=="Female")
        teM[i,5] <- sum(pheno[,1] %in% tmpfam & pheno[,"BreastCancer"]=="No" & pheno[,"Sex"]=="Male")
        
        a <- sum(tmp==tmp1[i]) / sum(pheno[,1] %in% tmpfam) 
        for(j in 1:4){
            famdis[i,j] <- a* teM[i,j+1]
        }
    }
    testr <- paste(teM[,1],teM[,2],teM[,3],teM[,4],teM[,5],sep=",")
    testr <- paste("(",testr,")",sep="")
    
    pdf(file="Family.pdf",width=12,height=10)
    par(mai=c(2,2,1,1))
    mp <- barplot(t(famdis[,c(4,3,2,1)]),ylim=c(0,max(rowSums(famdis))+5), space=0.4, col=c("green","cyan","blue","red") ,cex.axis=1.6,xlab="Number of family members",ylab="Number of families",cex.lab=2,legend = c("No Breast Cancer(Male)","No Breast Cancer(Female)","Breast Cancer(Male)","Breast Cancer(Female)"),main="Family Distribution",cex.main=2 )
    axis(1, at=mp, labels=tmp1,cex.axis=2)
    text(x=mp,y=rowSums(famdis),labels=testr,pos=3,cex=0.8)
    text(x=mp[5],y=max(rowSums(famdis))/2+50,labels="(#subject, #case(F), #case(M), #non-case(F), #non-case(M))",cex=1)
    dev.off()   
    
    pheno <- pheno_all()
    ## the number of cases in each family
    fams <- unique(pheno[,1])
    numcases <- rep(0,length(fams))
    for(i in 1:length(fams)){
        numcases[i] <- sum(pheno[pheno[,1] %in% fams[i],"BreastCancer"]=="Yes")
    }
    
    tmp <- table(pheno[,1])
    ncol <- max(numcases)
    nrow <- sort(unique(tmp))
    barM <- matrix(0,length(nrow),ncol+1)
    testr <- 1:dim(barM)[1]
    for(i in 1:dim(barM)[1]){
        for(j in 1:dim(barM)[2]){
            onefams <- names(tmp)[tmp==nrow[i]]
            barM[i,j] <- sum(numcases[fams %in% onefams]==j-1)
        }
        testr[i] <- paste(barM[i,1:min(c(nrow[i]+1,dim(barM)[2]))],sep="",collapse=",")
    }
    testr <- paste("(",testr,")",sep="")
    
    pdf(file="case_perFamily.pdf",width=12,height=10)
    par(mai=c(2,2,1,1))
    mp <- barplot(t(barM),ylim=c(0,max(rowSums(barM))+5), space=0.6, col=c("black","cyan","blue","red","yellow","green") ,cex.axis=1.6,xlab="Number of family members",ylab="",cex.lab=2,legend = c("no case","1 case","2 case","3 case","4 case","5 case"),main="Number of cases in each family",cex.main=2)
    axis(1, at=mp, labels=nrow,cex.axis=2)
    text(x=mp,y=rowSums(barM),labels=testr,pos=3,cex=0.8)
    dev.off()
    
}

updFam <- function(){
    source("SKAT_ana.R")
    #tsvf <- list.files("/home/local/ARCS/yshen/data/WENDY/BreastCancer/Regeneron/Filtering_for_Qiang",".tsv$")
    #tsvs <- basename(tsvf)
    #tsvs <- gsub(".tsv","",tsvs)
    pheno <- pheno_all()
    #pheno <- pheno[pheno[,3] %in% tsvs,]

    fams <- pheno[,1]
    print(length(unique(fams)))
    
    sifam <- names(table(fams))
    sifam <- sifam[table(fams)==1]
    length(sifam)
    
    twofam <- setdiff(fams,sifam)
    length(pheno[pheno[,1] %in% twofam,3])
    
    svgf <- list.files("/home/local/ARCS/qh2159/breast_cancer/pedigree/Family_Pedigree",".svg$")
    svgs <- basename(svgf)
    svgs <- gsub(".svg","",svgs)
    length(intersect(sifam,svgs))
    length(intersect(twofam,svgs))
    length(svgs)
    length(pheno[pheno[,1] %in% intersect(twofam,svgs) ,3])
    
    
    ## pedigree information predicted by Primus with second degree information
    pedf <- "family/Pedigree_sec.txt"
    ped <- read.delim(pedf)
    subs <- ped[,3]==0 & ped[,4]==0
    ped <- ped[!subs,]
    ped <- ped[,c(2,3,4)]
    
    ## pedigree information predicted by Primus with first degree information
    pedf <- "family/Pedigree_fir.txt"
    ped_1 <- read.delim(pedf)
    subs <- ped_1[,3]==0 & ped_1[,4]==0
    ped_1 <- ped_1[!subs,]
    ped_1 <- ped_1[,c(2,3,4)]
    
    tmp <- intersect(ped_1[,1],ped[,1])
    ped <- ped[!(ped[,1] %in% tmp),]
    
    preped <- rbind(ped,ped_1)
    preped <- preped[preped[,1] %in% pheno[,3],]
    
    length( intersect(unique(pheno[pheno[,3] %in% preped[,1] ,1]),sifam))
    length( intersect(unique(pheno[pheno[,3] %in% preped[,1] ,1]),twofam))
    length(pheno[pheno[,1] %in% intersect(unique(pheno[pheno[,3] %in% preped[,1] ,1]),twofam) ,3])
    
    length(intersect(union(svgs,pheno[pheno[,3] %in% preped[,1] ,1]),sifam))
    length(intersect(union(svgs,pheno[pheno[,3] %in% preped[,1] ,1]),twofam))
    
    
    ## missed family IDs  
    allpheno <- read.csv("data/WES BCFR phenotypic data.csv")
    allfams <- unique(allpheno[,1])
    svgf <- list.files("/home/local/ARCS/qh2159/breast_cancer/pedigree/Family_Pedigree",".svg$")
    svgs <- basename(svgf)
    svgs <- gsub(".svg","",svgs)
    
    missed <- setdiff(allfams,svgs)
    
}

## step 1: prepare the pedigree family information and kinship analysis files
write_ped <- function(){

    ## phenotype information
    pheno <- read.csv("data/WES BCFR phenotypic data.csv")
    ## ped file based on vcf file (vcf file from Ashley based on common SNPs)
    pedf <- "family/aa.ped"
    ## family information inferred from Primus
    firf <- "family/FirstDegreeTable_INDIVID.tsv"
    secf <- "family/SecondDegreeTable_INDIVID.tsv"
    firin <- read.delim(firf,sep="\t")
    sedin <- read.delim(secf,sep="\t")
    firin <- firin[!grepl("Missing",firin[,"IID"]),]
    sedin <- sedin[!grepl("Missing",sedin[,"IID"]),]
    
    firped <- "family/FirstDegree.ped"
    secped <- "family/SecondDegree.ped"
    con1 <- file(firped,"w");
    con2 <- file(secped,"w");
    
    con <- file(pedf,'r');
    k <- 1
    line = readLines(con,n=1);
    while(length(line)!=0){
        tmp <- unlist(strsplit(line,"\t"))
        tmp2 <- tmp
        n <- length(tmp)
        if(tmp[2] %in% pheno[,3]){
            tmp[1] <- pheno[pheno[,3]==tmp[2],1]
            tmp[5] <- pheno[pheno[,3]==tmp[2],"Sex"]
            tmp[6] <- pheno[pheno[,3]==tmp[2],"BreastCancer"]
            tmp2[1] <- tmp[1]
            tmp2[5] <- tmp[5]
            tmp2[6] <- tmp[6]
            
            sub <- which(firin[,"IID"]==pheno[pheno[,3]==tmp[2],2])
            if(length(sub) > 0){
                sub <- sub[1]
                tmp[3] <- ifelse(grepl("Missing",firin[sub,"PID"]),0,firin[sub,"PID"])
                tmp[4] <- ifelse(grepl("Missing",firin[sub,"MID"]),0,firin[sub,"MID"])
                if(tmp[3]!=0){tmp[3] <- pheno[pheno[,2]==tmp[3],3];}
            }
            
            sub <- which(sedin[,"IID"]==pheno[pheno[,3]==tmp[2],2])
            if(length(sub) > 0){
                sub <- sub[1]
                tmp2[3] <- ifelse(grepl("Missing",sedin[sub,"PID"]),0,sedin[sub,"PID"])
                tmp2[4] <- ifelse(grepl("Missing",sedin[sub,"MID"]),0,sedin[sub,"MID"])
                if(tmp2[3]!=0){tmp2[3] <- pheno[pheno[,2]==tmp2[3],3];}
                if(tmp2[4]!=0){tmp2[4] <- pheno[pheno[,2]==tmp2[4],3];} 
            }
        }
        write(tmp,con1,ncolumns=n,append=TRUE,sep="\t")
        write(tmp2,con2,ncolumns=n,append=TRUE,sep="\t")
        k <- k+1
        print(k)
        line = readLines(con,n=1);
    }
    close(con)
    close(con1)
    close(con2)

}

write_pedigree <- function(){
    
    con1 <- file("family/Pedigree_sec.txt","w")
    cols <- c("famid","id","father.id","mother.id","Sex","Affect")
    write(cols,con1,ncolumns=6,append=TRUE,sep="\t")
    
    secped <- "family/SecondDegree.ped"
    con <- file(secped,'r');
    k <- 1
    line = readLines(con,n=1);
    while(length(line)!=0){
        tmp <- unlist(strsplit(line,"\t"))
        tmp1 <- tmp[1:6]
        write(tmp1,con1,ncolumns=6,append=TRUE,sep="\t")
        k <- k+1
        #print(k)
        line = readLines(con,n=1);
    }
    close(con)
    close(con1)
    
    con1 <- file("family/Pedigree_fir.txt","w")
    cols <- c("famid","id","father.id","mother.id","Sex","Affect")
    write(cols,con1,ncolumns=6,append=TRUE,sep="\t")
    
    secped <- "family/FirstDegree.ped"
    con <- file(secped,'r');
    k <- 1
    line = readLines(con,n=1);
    while(length(line)!=0){
        tmp <- unlist(strsplit(line,"\t"))
        tmp1 <- tmp[1:6]
        write(tmp1,con1,ncolumns=6,append=TRUE,sep="\t")
        k <- k+1
        #print(k)
        line = readLines(con,n=1);
    }
    close(con)
    close(con1)
    
}

## step 2: run famSKAT in different levels
parallelfamSKAT <- function(flag){
    source("Faminfo.R")
    library(parallel)
    #mclapply(1:20,function(kk) run_famSKAT(kk,FALSE,flag),mc.cores = 20)
    #mclapply(1:20,function(kk) run_famSKAT(kk,TRUE,flag),mc.cores = 20)
    
    mclapply(19:20,function(kk) run_famSKAT(kk,FALSE,flag),mc.cores = 2)
    mclapply(19:20,function(kk) run_famSKAT(kk,TRUE,flag),mc.cores = 2)
}

parallelsamSKAT <- function(){
    source("Faminfo.R")
    library(parallel)
    
    mclapply(1:4,function(kk) runsmall_famSKAT(kk),mc.cores = 4)
}

run_famSKAT <- function(kk,sig,flag){
    
    source("family/famSKAT_v1.7_10312012.R")
    source("SKAT_ana.R")
    pheno <- pheno_all()
    
    idi <- as.vector(pheno[,2])
    fullkins <- getKinshipMatrix(flag)
    allped <- colnames(fullkins)
    idi <- intersect(idi,allped)
    id <- pheno[match(idi,pheno[,2]),3]
    colnames(fullkins)[match(idi,colnames(fullkins))] <- id
    rownames(fullkins)[match(idi,rownames(fullkins))] <- id
    
    #subs <- match(id,allped)
    #fullkins <- as.matrix(fullkins)[subs,subs]
    
    phe <- as.vector(pheno[match(id,pheno[,3]),"BreastCancer"])
    phe[phe=="Yes"] <- 1
    phe[phe=="No"] <- 0
    phe <- as.numeric(phe)
    
    pcaf <- "family/BC_Regeneron.plus.HapMap.pca.evec"
    covs <- Covariate_phe(pheno,pcaf,id)
    
    dirstr <- "famSKATresult/"
    cols <- c("Gene","Variant(#)","#case","#control","fold_enrich","pvalue")
    vartype <- c("LGD","D-mis","indels","LGD+D-mis","ALL")
    poptype <- c("Jewish","Hispanic","JH","All")
    
    genos <- genotype_wts(id,sig)
    fig <- floor((kk-1)/4) + 1
    pop <- ifelse(kk %% 4==0,4,kk %% 4)
    
    ### run with one flag, sig and flag
    oneresult <- subfamSKAT(genos,fig,pop,phe,id,covs)
    Zsub <- oneresult$Z
    fres <- oneresult$fres
    wtssub <- dbeta(fres,1,25)
    onelist <- oneresult$onelist
    phesub <- oneresult$phe
    idsub <- oneresult$id
    covssub <- oneresult$covs
    
    gT <- singlefamSKATg(phesub,idsub,fullkins,covssub,Zsub,wtssub,onelist)
    colnames(gT) <- cols
    write.table(gT,file=paste(dirstr,"Gene_",sig,"_",poptype[pop],"_",vartype[fig],"_",flag,".txt",sep=""),row.names=FALSE,quote=FALSE,sep="\t")
    
    if(fig==5){
        vT <- singlefamSKATv(phesub,idsub,fullkins,covssub,Zsub,wtssub,onelist)
        colnames(vT) <- cols
        write.table(vT,file=paste(dirstr,"Variant_",sig,"_",poptype[pop],"_",flag,".txt",sep=""),row.names=FALSE,quote=FALSE,sep="\t")
    }
    
}

runsmall_famSKAT <- function(set4){
    source("family/famSKAT_v1.7_10312012.R")
    source("SKAT_ana.R")
    pheno <- pheno_all()
    
    flag=1;
    sig=FALSE;
    kk=20;
    trsV <- c("trio","fam")
    
    idi <- as.vector(pheno[,2])
    fullkins <- getKinshipMatrix(1)
    allped <- colnames(fullkins)
    idi <- intersect(idi,allped)
    id <- pheno[match(idi,pheno[,2]),3]
    colnames(fullkins)[match(idi,colnames(fullkins))] <- id
    rownames(fullkins)[match(idi,rownames(fullkins))] <- id
    idmap <- read.table("family/BC_Hap_popMap.txt")
    id <- intersect(id,idmap[,1])
    
    if(set4 <=2) trs <- trsV[set4]
    if(set4 >2 ) trs <- trsV[set4-2]
    id <- triosall(trs,idi,id,pheno)
    
    phe <- as.vector(pheno[match(id,pheno[,3]),"BreastCancer"])
    phe[phe=="Yes"] <- 1
    phe[phe=="No"] <- 0
    phe <- as.numeric(phe)
    
    if(set4<=2){
        pcaf <- "family/BC_Regeneron.plus.HapMap.pca.evec"
        covs <- Covariate_phe(pheno,pcaf,id)
    }else{
        pcaf <- "family/Combined_data_for_eigenstrat.7.Q"
        covs <- Covariate_admix(pheno,pcaf,id)
        covs <- covs[,1:8]
    }
    dirstr <- "famSKATresult/"
    cols <- c("Gene","Variant(#)","#case","#control","fold_enrich","pvalue")
    
    genos <- genotype_wts(id,sig)
    ### run one
    Z <- genos$Z
    fres <- genos$fres
    wts <- dbeta(fres,1,25)
    onelist <- genos$alllist
    
    gT <- singlefamSKATg(phe,id,fullkins,covs,Z,wts,onelist)
    colnames(gT) <- cols
    write.table(gT,file=paste(dirstr,"Gene_",set4,".txt",sep=""),row.names=FALSE,quote=FALSE,sep="\t")
    
    vT <- singlefamSKATv(phe,id,fullkins,covs,Z,wts,onelist)
    colnames(vT) <- cols
    write.table(vT,file=paste(dirstr,"Variant_",set4,".txt",sep=""),row.names=FALSE,quote=FALSE,sep="\t")

}

qqplot_p <- function(){
    ## qq plots for pvalues in variant and gene level
    library(Haplin)
    dirstr <- "famSKATresult/"
    vartype <- c("LGD","D-mis","indels","LGD+D-mis","ALL")
    poptype <- c("Jewish","Hispanic","JH","All")
    for(flag in 1){
    for(sig in c(FALSE,TRUE)){
        for(pop in 1:4){
            for(fig in 1:5){
                gfile <- paste(dirstr,"Gene_",sig,"_",poptype[pop],"_",vartype[fig],"_",flag,".txt",sep="")
                if(file.exists(gfile)){
                    gT <- read.delim(gfile,sep="\t")
                    pvals <- gT[,"pvalue"]
                    names(pvals) <- gT[,"Gene"]
                    pdf(file=paste(dirstr,"Gene_",sig,"_",poptype[pop],"_",vartype[fig],"_",flag,".pdf",sep=""),width=10,height=10)
                    pQQ(pvals, nlabs = sum(pvals<0.05), conf = 0.95, mark = 0.05)
                    dev.off()
                }
            }
            
            vfile <- paste(dirstr,"Variant_",sig,"_",poptype[pop],"_",flag,".txt",sep="")
            if(file.exists(vfile)){
            vT <- read.delim(vfile,sep="\t")
            pvals <- vT[,"pvalue"]
            names(pvals) <- vT[,"Gene"]
            pdf(file=paste(dirstr,"Variant_",sig,"_",poptype[pop],"_",flag,".pdf",sep=""),width=10,height=10)
            pQQ(pvals, nlabs = sum(pvals<0.05), conf = 0.95, mark = 0.05)
            dev.off()
            }
        }
    }
    }
    
}

getKinshipMatrix <- function(flag=1){
    ## one: compute for pedigree kinship based on R package kinship::makekinship
    ## two: compute for genomic kinship based on Ashley PCA ped file based on king
    ## three: compute for genomic kinship with Primus first degree inferred pedigree based on software king
    ## four: compute for genomic kinship with Primus second degree inferred pedigree based on software king
    library(kinship)
    #filenames <- c("data/ALL_pedigree.csv","family/king.kin0","family/FirstDegree.kin0","family/SecondDegree.kin0")
    filenames <- c("data/ALLadd_pedigree.csv","family/king.kin0","family/FirstDegree.kin0","family/SecondDegree.kin0")
    filen <- filenames[flag]
    if(flag==1){
        fullped <- read.csv(filen)
        #fullkins <- makekinship(fullped$famid, fullped$id, fullped$father.id, fullped$mother.id)
        fullkins <- makekinship(fullped[,1], fullped[,2], fullped[,3], fullped[,4])
    }else{
        ibd <- kingkinship(filen)
        #fullkins[fullkins < 0] <- 0
        fullkins <-  bdsmatrix.ibd(ibd[,1],ibd[,2], ibd[,3], diagonal=0.5)
    }
    
    fullkins
}

kingkinship <- function(filen){
    tmp <- read.delim(filen,sep="\t")
    #ids <- union(tmp[,"ID1"],tmp[,"ID2"])
    #n <- length(ids)
    #subs <- cbind(tmp[,"ID1"],tmp[,"ID2"])
    #fullkins <- matrix(0,n,n,dimnames=list(ids,ids))
    #fullkins[subs] <- tmp[,"Kinship"]

    #fullkins
    ibd <- tmp[,c("ID1","ID2","Kinship")]
    ibd[ibd[,3] < 0,3] <- 0
    ibd
}

triosall <- function(trs,idi,id,pheno){

    pedf <- "data/ALL_pedigree.csv"
    peds <- read.csv(pedf)
    
    peds0 <- matrix(9,length(id),4) ## 9 for miss 
    peds0[,1] <- pheno[match(id,pheno[,3]),1]
    peds0[,2] <- id
    for(i in 1:length(id)){
        if(any(peds[,2]==idi[i])){
            fid <- peds[which(peds[,2]==idi[i]),3]
            mid <- peds[which(peds[,2]==idi[i]),4]
            
            if(fid %in% pheno[,2]){
                peds0[i,3] <- pheno[pheno[,2]==fid,3]
            }
            if(mid %in% pheno[,2]){
                peds0[i,4] <- pheno[pheno[,2]==mid,3]
            }
            
        }
    } 
    peds <- peds0
    
    if(trs=="trio"){
        id0 <- unique(as.vector(peds[(peds[,3]!=9 & peds[,4]!=9),2:4]))
    }else if(trs=="fam"){
        id0 <- unique(as.vector(peds[(peds[,3]!=9 | peds[,4]!=9),2:4]))
    }
    
    id0 <- intersect(id0,id)
    
    id0
}

Covariate_phe <- function(pheno,pcaf,id){

    alldat <- read.table(pcaf) ## include Regeneron and Hapmap data; top 10 pca 
    whi.dat <- grep("NA", alldat[,1], invert=T)
    alldat <- alldat[whi.dat,]
    alldat[,1] <- sapply(1:dim(alldat)[1], function(i) unlist(strsplit(alldat[i,1],":"))[2])
    ## covariates: sex, age and pc1
    X <- matrix(0,length(id),3,dimnames=list(id,c("sex","age","pc1")))
    X[,1] <- pheno[match(id,pheno[,3]),"Sex"]
    X[X[,1]=="Female",1] <- 1
    X[X[,1]=="Male",1] <- 0
    
    X[,2] <- pheno[match(id,pheno[,3]),"BIRTHDT"]
    X[,2] <- sapply(1:dim(X)[1],function(i) 114 - as.numeric(unlist(strsplit(X[i,2],"/"))[3]) )
    
    X[,3] <- alldat[match(id,alldat[,1]),2]
    X <- as.numeric(X)
    X <- matrix(X,ncol=3)
    
    X
}

Covariate_admix <- function(pheno,pcaf,id){
    
    idmap <- read.table("family/BC_Hap_popMap.txt")
    alldat <- as.matrix(read.table(pcaf)) ## include Regeneron and Hapmap data; top 10 pca 
    ## covariates: sex, age and pc1
    X <- matrix(0,length(id),9,dimnames=list(id,c("sex","age",paste("pop",1:7,sep=""))))
    X[,1] <- pheno[match(id,pheno[,3]),"Sex"]
    X[X[,1]=="Female",1] <- 1
    X[X[,1]=="Male",1] <- 0
    
    X[,2] <- pheno[match(id,pheno[,3]),"BIRTHDT"]
    X[,2] <- sapply(1:dim(X)[1],function(i) 114 - as.numeric(unlist(strsplit(X[i,2],"/"))[3]) )
    X[,3:9] <- alldat[match(id,idmap[,1]),]
    mode(X) <- "numeric"
    
    X
}

genotype_wts <- function(id,sig){
    source("indexcase_burden.R")
    hotf <- "hotspots/hotf_cos_2"
    load("alllist_10_20")
    mis <- c("nonframeshiftdeletion","nonframeshiftinsertion","nonsynonymousSNV")
    lof <- c("frameshiftdeletion","frameshiftinsertion","stopgain","stoploss","none")
    alllist <- alllist[alllist[,"VariantClass"] %in% c(lof,mis),]
    alllist <- alllist[alllist[,"Subject_ID"] %in% id,]
    alllist <- filter_variant(alllist,sig)
    alllist <- alllist[alllist[,"Variantfiltering"],]
    #alllist <- subSKAT(alllist,fig,pop)
    alllist <- hotspot_mis(hotf,alllist,mis)
    
    
    ## MAF (minor-allele frequency): 
    freN <- c("ExAC.nfe.freq","ExAC.afr.freq")
    fres <- sapply(1:dim(alllist)[1], function(i){
        tmp <- unlist(strsplit(alllist[i,"INFO"],";"))
        tmp2 <- unlist(strsplit(tmp,"="))
        tmp3 <- tmp2[match(freN,tmp2)+1]
        if(all(is.na(tmp3))){0;}else{
        if(is.na(tmp3[1])){a1=1;}else{
        a1 <- unlist(strsplit(tmp3[1],","))
        a1[a1=="."] <- 0
        a1 <- max(as.numeric(a1))
        }
        if(is.na(tmp3[2])){a2=1;}else{
        a2 <- unlist(strsplit(tmp3[2],","))
        a2[a2=="."] <- 0
        a2 <- max(as.numeric(a2))
        }
        min(a1,a2)
        }
    })
    
    vars <- paste(alllist[,1],alllist[,2],alllist[,4],alllist[,5],sep="_")
    names(fres) <- vars
    vars <- unique(vars)
    fres <- fres[match(vars,names(fres))]
    
    ### genotype matrix
    n.case <- length(id)
    n.var <- length(vars)
    Z <- matrix(0,n.case,n.var,dimnames=list(id,vars))
    for(i in 1:n.case){
        tmp <- alllist[alllist[,"Subject_ID"]==id[i],]
        svar <- paste(tmp[,1],tmp[,2],tmp[,4],tmp[,5],sep="_")
        geo <- rep(2,length(svar))
        geo[tmp[,"GT"]=="0/0"] <- 0
        geo[tmp[,"GT"]=="0/1"] <- 1
        Z[i,match(svar,vars)] <- geo
    }
    
    list(fres=fres,Z=Z,alllist=alllist)
    
}

hotspot_mis <- function(hotf,onelist,mis){
    
    load(hotf)
    hotg <- names(hots)
    misS <- rep(TRUE,dim(onelist)[1])
    subs <- which((onelist[,"VariantClass"] %in% mis) & (nchar(onelist[,"REF"]) == nchar(onelist[,"ALT"])))
    sublist <- onelist[subs,]
    
    ### only missense mutations in hotspots
    p.case <- sapply(1:dim(sublist)[1], function(i) {
        tmp <- unlist(strsplit(sublist[i,"AAchange"],":"))[5]
        acid <- gsub("\\D","",tmp)
        k <- which(hotg==sublist[i,"Gene"])
        if(length(k)>0){acid %in% hots[[k]];
        }else{FALSE;}
    })
    
    misS[subs] <- p.case
    onelist <- onelist[misS,]
    onelist
}

subfamSKAT <- function(genos,fig,pop,phe,id,covs){
    Z <- genos$Z
    fres <- genos$fres
    onelist <- genos$alllist
    
    
    ## sub columns corresponding to variants
    source("SKAT_ana.R")
    onelist <- subSKAT(onelist,fig,pop)
    vars <- unique(paste(onelist[,1],onelist[,2],onelist[,4],onelist[,5],sep="_"))
    subs <- match(vars,colnames(Z))
    Z <- Z[,vars]
    fres <- fres[subs]
    
    ## sub rows corresponding to subjects
    bc.pop <- read.delim("data/WES_BCFR_phenotypic_data-19062015.txt")[,1:5]
    bc.pop[,4] <- paste(bc.pop[,4], bc.pop[,5], sep="")
    bc.pop <- bc.pop[,-5]
    Jp <-  bc.pop[bc.pop[,4] %in% "J",3]
    Hp <-  bc.pop[bc.pop[,4] %in% "H",3]
    coln <- ifelse(any(grepl("SubID",colnames(onelist))), "SubID","Subject_ID")
    
    if(pop==1){ onep = Jp; }
    if(pop==2){ onep = Hp; }
    if(pop==3){ onep = c(Jp,Hp); }
    if(pop==4){ onep = id;}
    ## cannot change the orders
    Z <- Z[rownames(Z) %in% onep,];
    idsub <- intersect(onep,id)
    phe <- phe[id %in% idsub]
    covs <- covs[id %in% idsub,]
    id <- id[id %in% idsub]
    
    list(Z=Z,fres=fres,onelist=onelist,phe=phe,id=id,covs=covs)

}

singlefamSKATg <- function(phe,id,fullkins,covs,Z,wts,onelist){
    ## single gene level
    genes <- unique(onelist[,"Gene"])
    varlist <- paste(onelist[,1],onelist[,2],onelist[,4],onelist[,5],sep="_")
    vars <- colnames(Z)
    vT <- matrix(0,length(genes),6)
    
    p <- sum(phe==1)/length(phe)
    subs <- phe==1
    a1 <- log(p/(1-p))
    phe0 <- phe
    phe0[subs] <- a1
    phe0[!subs] <- -a1
    
    tmp <- sapply(1:length(genes),function(i){
        onevars <- unique(varlist[onelist[,"Gene"]==genes[i]])
        oneG <- as.matrix(Z[,onevars])
        c(  
            length(onevars),
            length(intersect(id[phe==1],onelist[varlist %in% onevars,"Subject_ID"])),
            length(intersect(id[phe==0],onelist[varlist %in% onevars,"Subject_ID"])),
            famSKAT(phe0, oneG, id, fullkins, covs, h2=NULL, sqrtweights=wts[match(onevars,vars)], binomialimpute=FALSE, method="Kuonen", acc=NULL)$pvalue
        )
    })
    vT[,c(2,3,4,6)] <- t(tmp)
    vT[,5] <- (vT[,3]/sum(phe==1))/(vT[,4]/sum(phe==0))
    vT[,1] <- genes
    
    vT
}

singlefamSKATv <- function(phe,id,fullkins,covs,Z,wts,onelist){
    ## single variant level
    varlist <- paste(onelist[,1],onelist[,2],onelist[,4],onelist[,5],sep="_")
    vars <- colnames(Z)
    vT <- matrix(0,length(vars),6)
    
    p <- sum(phe==1)/length(phe)
    subs <- phe==1
    a1 <- log(p/(1-p))
    phe0 <- phe
    phe0[subs] <- a1
    phe0[!subs] <- -a1
    
    tmp <- sapply(1:length(vars),function(i){
        c( length(intersect(id[phe==1],onelist[varlist==vars[i],"Subject_ID"])),
           length(intersect(id[phe==0],onelist[varlist==vars[i],"Subject_ID"])),
           famSKAT(phe0, Z[,vars[i],drop=FALSE], id, fullkins, covs, h2=NULL, sqrtweights=wts[i], binomialimpute=FALSE, method="Kuonen", acc=NULL)$pvalue
        )
        })
    vT[,c(3,4,6)] <- t(tmp)
    vT[,5] <- (vT[,3]/sum(phe==1))/(vT[,4]/sum(phe==0))
    vT[,1] <- onelist[match(vars,varlist),"Gene"]
    vT[,2] <- vars
    
    vT
}

rewrite_allpeds <- function(){
     a <- read.csv("data/ALL_pedigree.csv")
     ids <- union(a[,2],union(a[,3],a[,4]))
     idd <- setdiff(ids,a[,2])
     
     tmp <- matrix(0,length(idd),4)
     tmp[,2] <- idd
     for(i in 1:length(idd)){
        tmp[i,1] <- a[which(a==idd[i],arr.ind=TRUE)[1],1]
     }
     colnames(tmp) <- names(a)
     allped <- rbind(a,tmp)
     write.csv(allped,file="data/ALLadd_pedigree.csv",row.names=FALSE)
     
}
