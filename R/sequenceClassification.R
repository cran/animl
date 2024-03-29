#' Leverage sequences to classify images
#'
#' This function applies image classifications at a sequence level by leveraging 
#' information from multiple images. A sequence is defined as all images at the same
#' camera/station where the time between consecutive images is <=maxdiff. This can improve
#' classification accuracy, but assumes that only one species is present in each sequence.
#' If you regularly expect multiple species to occur in an image or sequence don't use this function.
#' 
#' This function retains "Empty" classification even if other images within the
#' sequence are predicted to contain animals.
#' Classification confidence is weighted by MD confidence.
#'
#' @param animals sub-selection of all images that contain MD animals
#' @param empty optional, data frame non-animal images (empty, human and vehicle) that will be merged back with animal imagages
#' @param predictions data frame of prediction probabilities from the classifySpecies function
#' @param classes a vector or species corresponding to the columns of 'predictions'
#' @param emptyclass a string indicating the class that should be considered 'Empty'
#' @param stationcolumn a column in the animals and empty data frame that indicates the camera or camera station
#' @param sortcolumns optional sort order. The default is 'stationcolumnumn' and DateTime.
#' @param maxdiff maximum difference between images in seconds to be included in a sequence, defaults to 60
#'
#' @return data frame with predictions and confidence values for animals and empty images
#' @export
#'
#' @examples
#' \dontrun{
#' predictions <-classifyCropsSpecies(images,modelfile,resize=456)
#' animals <- allframes[allframes$max_detection_category==1,]
#' empty <- setEmpty(allframes)
#' animals <- sequenceClassification(animals, empty, predictions, classes,
#'                                   emptyclass = "Empty",
#'                                   stationcolumnumn="StationID", maxdiff=60)
#' }
sequenceClassification<-function(animals, empty=NULL, predictions, classes, 
                                 emptyclass="", stationcolumn, sortcolumns=NULL, maxdiff=60){
  if (!is(animals, "data.frame")) {
    stop("'animals' must be a Data Frame.")
  }  
  if (!is(predictions, "matrix")) {
    stop("'predictions' must be a matrix")
  }
  if(nrow(animals)!=nrow(predictions)){
    stop("'animals' and 'predictions' must have the same number of rows")
  }
  if(!is.null(sortcolumns) && sum(sortcolumns %in% colnames(animals))!=length(sortcolumns)){
    stop("not all sort columns are present in the 'animals' data.frame")
  }
  if(!is.null(empty) && (!setequal(colnames(animals)[!colnames(animals) %in%c("prediction","confidence")],colnames(empty)[!colnames(empty) %in% c("prediction","confidence")]))){
    stop("column names for animals and empty must be the same")
  }
  if (length(emptyclass)>1) {
    stop("'emptyclass' must be a vector of length 1")
  }
  if(!is.numeric(maxdiff) | maxdiff<0)
  {
    stop("'maxdiff' must be a number >=0")
  }
  if(length(classes)!=ncol(predictions))
  {
    stop("'classes' must have the same length as the number or columns in 'predictions'")
  }
  if(is.null(stationcolumn) | length(stationcolumn)>1){
    stop("please provide a single character values for 'stationcolumn'")
  }
  
  #if column conf does not exist add it as 1s
  if(!("conf" %in% colnames(animals))){
    animals$conf=1
  }
  
  #sort animals and predictions
  if(is.null(sortcolumns)){
    sortcolumns<-c(stationcolumn,"DateTime")
  }
  sort<-do.call(order,animals[,sortcolumns])
  
  
  animals<-animals[sort,]
  predsort<-predictions[sort,]
  
  #define which class is empty  
  if(emptyclass>""){
    emptycol<-which(classes == emptyclass)
  }
  
  i=1
  c=nrow(animals)/100
  
  #loop over all animals rows
  cat("Classifying animal images..\n")
  opb <- pbapply::pboptions(char = "=")
  pb <- pbapply::startpb(1, nrow(animals))
  
  conf=numeric(nrow(animals))
  predict=character(nrow(animals))
  
  while(i<=nrow(animals)){
    if(i > c){
      pbapply::setpb(pb, i) 
      c=c+nrow(animals)/100
    }
    rows<-i
    j=i+1
    
    while(!is.na(animals$DateTime[j]) & !is.na(animals$DateTime[i]) & j<nrow(animals) & animals[j,stationcolumn]==animals[i,stationcolumn] & difftime(animals$DateTime[j],animals$DateTime[i],units="secs")<=maxdiff){
      rows<-c(rows,j)
      j=j+1
    }
    #check if there are multiple crops in a sequence
    if(length(rows)>1){ #multiple boxes in the sequence
      predclass<-apply(predsort[rows,],1,which.max)
      if(length(emptycol)==0 | !(emptycol %in% predclass) | length(which(predclass %in% emptycol))==length(rows)){
        predsort2<-predsort[rows,]*animals$conf[rows]
        predbest<-apply(predsort2,2,mean)
        conf[rows]<-max(predsort2[,which.max(predbest)])
        predict[rows]<-classes[which.max(predbest)]
      }else{ #process sequences with some empty
        #select images for which all boxes are empty
        sel<-tapply(predclass==emptycol,animals$FilePath[rows],sum)==
          tapply(predclass==emptycol,animals$FilePath[rows],length)
        
        #classify images with species
        #boxes that are animals
        sel2<-which(animals$FilePath[rows] %in% names(sel[!sel]) & !(predclass %in% emptycol))
        sel3<-which(animals$FilePath[rows] %in% names(sel[!sel]))
        predsort2<-matrix(predsort[rows[sel2],]*animals$conf[rows[sel2]],ncol=ncol(predsort))
        predbest<-apply(predsort2,2,mean)
        conf[rows[sel3]]<-max(predsort2[,which.max(predbest)])
        predict[rows[sel3]]<-classes[which.max(predbest)]
        
        #classify empty images
        for(s in names(sel[sel])){
          sel2<-which(animals$FilePath[rows] %in% s)
          predbest<-apply(matrix(predsort[rows[sel2],]*animals$conf[rows[sel2]],ncol=ncol(predsort)),2,mean) 
          conf[rows[sel2]]<-max(predbest) 
          predict[rows[sel2]]<-classes[which.max(predbest)]
        }
      }
    }else{ #only one box in the sequence
      predbest<-predsort[rows,]
      conf[rows]<-max(predbest*animals$conf[rows])
      predict[rows]<-classes[which.max(predbest)]
    }
    i=j
  }
  animals$confidence<-conf
  animals$prediction=predict
  
  pbapply::setpb(pb, nrow(animals))
  pbapply::closepb(pb)
  
  if(!is.null(empty)){
    cat("Classifying empty, human and vehicle images..\n")
    #set common name to the same for all boxes in non-animal images
    #select files with multiple boxes
    t<-tapply(1:nrow(empty),empty$FilePath,function(x)x)
    t2<-lapply(t,length)
    t3<-which(t2>1)
    
    #setup progress bar
    cmax=length(unlist(t[t3]))
    opb <- pbapply::pboptions(char = "=")
    pb <- pbapply::startpb(1, cmax)
    pbapply::setpb(pb, 1)
    
    c=1
    conf=numeric(cmax)
    predict=character(cmax)
    rowsel<-numeric(cmax)
    #loop over all files with multiple boxes
    for(s in t3){
      sel<-t[s][[1]]
      rowsel[c:(c+length(sel)-1)]<-sel
      maxconf=which.max(empty$confidence[sel][empty$confidence[sel]<1])
      if(length(maxconf)==0){ #all empty
        conf[c:(c+length(sel)-1)]<-rep(empty$confidence[sel][1],length(sel))
        predict[c:(c+length(sel)-1)]<-rep(empty$prediction[sel][1],length(sel))     
      }else{ #object detected
        conf[c:(c+length(sel)-1)]<-rep(empty$confidence[sel][maxconf],length(sel))
        predict[c:(c+length(sel)-1)]<-rep(empty$prediction[sel][maxconf],length(sel))
      }
      pbapply::setpb(pb, c)
      c=c+length(sel)
    }
    pbapply::setpb(pb, cmax)
    pbapply::closepb(pb)
    
    empty[rowsel,]$confidence<-conf
    empty[rowsel,]$prediction<-predict
    
    t<-unique(animals[,c("FilePath","confidence","prediction")])
    t2<-match(empty$FilePath,t$FilePath)
    t3<-!is.na(t2)
    empty[t3,]$confidence<-t[t2[t3],]$confidence
    empty[t3,]$prediction<-t[t2[t3],]$prediction
    
    #combine animal and empty images
    alldata<-rbind(empty,animals)
    alldata[do.call(order,alldata[,sortcolumns]),]
  }else{
    animals[do.call(order,animals[,sortcolumns]),]
  }
  
}

