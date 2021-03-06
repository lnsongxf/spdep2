## test file

library(Matrix)
library(MASS)
library(spdep)
source('parse.R')
source('utils.R')

#W<-structure(c(0, .5, 0.5, 0.5, 0, 0.5, 0.5, 0.5, 0), .Dim = c(3L, 3L))

prior = NULL
#prior<-prior_parse(NULL,2)
#prior$ldetflag<-0
#prior$rmin<-0.1
#prior$rmax<-0.99#If this is set to 1 then problem when interpolating log-det's

#prior$metflag<-0#M-H sampler

nsim<-1000
xx<-matrix(rnorm(nsim*2), ncol=2)
W<-nb2mat(knn2nb(knearneigh(xx, 2)))

y<-matrix(5*rnorm(nsim), ncol=1)
x<-matrix(rnorm(2*nsim),ncol=2)
xWx<-cbind(x, W%*%x)
y<-solve(diag(nsim)-0.5*W, y+xWx%*%matrix(c(1,5, 10, 2), ncol=1))


ndraw=1000
nomit=500

source('sdm_g.R')

prior<-prior_parse(NULL, k=2+2)
prior$rmin<-.01
prior$rmax<-.99
prior$novi_flag<-1

results=sdm_g(y,x,W,ndraw,nomit,prior)
plot(density(results$pdraw), type="l", main="rho")



#Bigger example
library(spdep)
data(boston)

W<-nb2mat(boston.soi)
n<-nrow(W)
x<-cbind(rep(1, n), rnorm(n))
xWx<-cbind(x, W%*%x[,-1])


y<-matrix(xWx[,1]+5*xWx[,2]+10*xWx[,3]+rnorm(n), ncol=1)
y<-solve(diag(nrow(W))-0.9*W)%*%y


#Heteroc.  model
prior<-prior_parse(NULL, k=ncol(xWx))
prior$novi_flag<-0
results<-sdm_g(y, x, W, 1500, 500, prior)
plot(density(results$pdraw), type="l", main="rho")
summary(results$pdraw)



#Homoc. model
prior$novi_flag<-1
results1<-sdm_g(y, x, W, 1500, 500, prior)
plot(density(results1$pdraw), type="l", main="rho")
summary(results1$pdraw)




#Example with Boston housing data
#Code from help(boston, package="spdep")
hr0 <- lm(log(MEDV) ~ CRIM + ZN + INDUS + CHAS + I(NOX^2) + I(RM^2) +
      AGE + log(DIS) + log(RAD) + TAX + PTRATIO + B + log(LSTAT)
, data=boston.c)

y<-matrix(log(boston.c$MEDV), ncol=1)
x<-model.matrix(hr0)
xlag<-cbind(x, W%*%x[,-1])

prior<-prior_parse(NULL, k=ncol(x))
prior$novi_flag<-1
prior$metflag<-1

resultsx<-sar_g(y, x, W, 3000, 1000, prior)
#plot(results$pdraw, type="l", main="rho")
plot(density(resultsx$pdraw), type="l", main="rho")
summary(resultsx$pdraw)
cbind(apply(resultsx$bdraw, 2, mean), apply(resultsx$bdraw, 2, sd))

#With lagged covariates
prior<-prior_parse(NULL, k=ncol(xlag))
prior$novi_flag<-1
prior$metflag<-1
resultsxlag<-sar_g(y, xlag, W, 3000, 1000, prior)
#plot(results$pdraw, type="l", main="rho")
plot(density(resultsxlag$pdraw), type="l", main="rho")
summary(resultsxlag$pdraw)
cbind(apply(resultsxlag$bdraw, 2, mean), apply(resultsxlag$bdraw, 2, sd))


