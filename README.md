# Getting and Cleaning Data Course Project

## Introduction

The materials in the repository are to satisfy the requirements
of the course project in the Getting and Cleaning Data course
that is part of the Data Science Certificate specialization
in Coursera from the John Hopkins University.

To quote:

> The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

## Contents

* README.md -- this file, covers what is here and why.

* CodeBook.md -- full explanation of the data file generated 
  during these analyses.

* run_analysis.R -- the R script that performs all of the steps
  to produce the specified tidy dataset.  Every action for this exercise
  is contained in the one script (loads each file, massages the data,
  add labels as necessary, combines into a tidy data form, computes
  averages, writes results; also the script will if necessary re-download
  and/or re-unzip the source file as provided to the class.)

## Processing

The purpose of the code in this repository is to process a set of
intermediate experiment results into something of a summary form
that is a single tidy dataset.

All processing in this case is performed in the one 'run_analysis.R'
script; a single invocation should be sufficient.

The script will create a new file: 'UCI-HAR-tidied-and-averaged.txt'.
The specific contents of this file are described in CodeBook.md

The results of this processing will be a single text file that can
be read into R simply with:

    read.table('UCI-HAR-tidied-and-averaged.txt', header = TRUE)

## Background

This assignment is based on test and training sets provided
to the UCI Machine Learning Repository
as the Human Activity Recognition project.

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Citation: Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. A Public Domain Dataset for Human Activity Recognition Using Smartphones. 21th European Symposium on Artificial Neural Networks, Computational Intelligence and Machine Learning, ESANN 2013. Bruges, Belgium 24-26 April 2013.
