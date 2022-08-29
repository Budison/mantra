#!/bin/bash

showWelcomeMessage() {
  printf "\n\e[1m=====================\n"
  printf "MANTRA SCRIPT STARTED\n"
  printf "=====================\e[0m\n"
}

verifyIfTreeExists() {
  if ! command tree -v &>/dev/null; then
    printf "\e[1;91m[ERROR]:\e[0m 'tree' package which is needed to run the script hasn't been detected and the script has stopped. Try to install 'tree' package using command 'sudo apt-get install tree'.\n\n"
    exit
  fi
}

verifyIfGitExists() {
  if ! command git --version &>/dev/null; then
    printf "\e[1;91m[ERROR]:\e[0m 'git' package which is needed to run the script hasn't been detected and the script has stopped. Try to install 'git' package using command 'sudo apt-get install git'.\n\n"
    exit
  fi
}

verifyIfTwoArguments() {
  if [ $# != 2 ]; then
    printf "\e[1;91m[ERROR]:\e[0m The script must be provided with two arguments. The first one should be an absolute path where the project directory is to be created and the second one should be the project name. This condition hasn't been met and the script has stopped.\n\n"
    exit
  fi
}

verifyIfCorrectPath() {
  if [[ ! "$1" =~ ^\/.* ]]; then
    printf "\e[1;91m[ERROR]:\e[0m As the first argument for the script an absolute path where the project directory is to be created should be provided. This condition hasn't been met and the script has stopped.\n\n"
    exit
  fi
}

verifyIfCorrectName() {
  if [[ ! "$1" =~ ^[a-z]{1}([a-z_0-9]*)$ ]]; then
    printf "\e[1;91m[ERROR]:\e[0m The provided project name may consist only of lower case alphanumericals and _ (underscore); the first character should be a letter. This condition hasn't been met and the script has stopped.\n\n"
    exit
  fi
}

verifyIfProjectDirectoryExists() {
  if [ -d $1 ]; then
    printf "\e[1;91m[ERROR]:\e[0m The project already exists in \e[3m$1\e[0m. The script has stopped.\n\n"
    exit
  fi
}

createProjectDirectory() {
  mkdir -p $1
  printf "\e[1;96m[STATUS]:\e[0m The project directory \e[3m$1\e[0m has been created.\n"
}

createFileStructure() {
  mkdir -p $1/src/{main/{java/com/github/budison/$2,resources},test/java/com/github/budison/$2}
  touch $1/src/main/java/com/github/budison/$2/Main.java
  touch $1/src/test/java/com/github/budison/$2/MainTest.java
  touch $1/pom.xml
  touch $1/README.md
  printf "\e[1;96m[STATUS]:\e[0m The following file structure for the project has been created:\n"
  tree $1
}

insertContentToMain() {
  mainFile=$1/src/main/java/com/github/budison/$2/Main.java
  cat >$mainFile <<EOF
package com.github.budison.$2;

public class Main {

    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }
}	
EOF
  printf "\e[1;96m[STATUS]:\e[0m Default Java-content has been added to \e[3mMain.java\e[0m.\n"
}

insertContentToMainTest() {
  mainTestFile=$1/src/test/java/com/github/budison/$2/MainTest.java
  cat >$mainTestFile <<EOF
package com.github.budison.$2;

import org.testng.annotations.Test;

import static org.testng.Assert.*;

public class MainTest {   
    @Test
    public void sampleTrueTest() {
        assertTrue(true);
    }
}
EOF
  printf "\e[1;96m[STATUS]:\e[0m Default content has been added to \e[3mMainTest.java\e[0m.\n"
}

downloadPom() {
  wget "https://gist.github.com/Budison/d9ea6456df140f74976cd5d4ba20beef/pom.xml" -O "$1/pom.xml"
  
  printf "\e[1;96m[STATUS]:\e[0m Default Maven-content has been added to \e[3mpom.xml\e[0m.\n"
}

setPom() {
  pomFile=$1/pom.xml
  projectName=$2
  sed -i "s/#GROUPID#/com.github.budison.$projectName/g" $pomFile
  sed -i "s/#ARTIFACTID#/$projectName/g" $pomFile
  sed -i "s/#APP_NAME#/$projectName/g" $pomFile
}

insertContentToReadme() {
  readmeFile=$1/README.md
  projectName=$2
  date=$(date +%F)
  cat >$readmeFile <<EOF
# $projectName

This project was created on $date from a template.
EOF
  printf "\e[1;96m[STATUS]:\e[0m Default Readme-content has been added to \e[3mREADME.md\e[0m.\n"
}

addGitignore() {
  touch $1/.gitignore
  gitignoreFile=$1/.gitignore
  cat >$gitignoreFile <<EOF
# All files with .class extension:
*.class

# All files with .log extension + all files and directories named 'logs':
*.log
**/logs

# 'target' directory located directly in the project directory:
/target

# All files and directories which names start with . (dot), 
# except .git, .gitattributes and .gitignore:
.*
!/.git
!.gitattributes
!.gitignore
EOF
  printf "\e[1;96m[STATUS]:\e[0m \e[3m.gitignore\e[0m has been created. It sets git to ignore:
	   \055 all files with \e[3m.class\e[0m extension
	   \055 all files with \e[3m.log\e[0m extension
	   \055 all files and directories named \e[3mlogs\e[0m
	   \055 \e[3mtarget\e[0m directory located directly in the project directory
	   \055 all files and directories which names start with \e[3m. (dot)\e[0m,
	     except \e[3m.git\e[0m, \e[3m.gitattributes\e[0m and \e[3m.gitignore\e[0m\n"
}

addGitattributes() {
  touch $1/.gitattributes
  gitattributesFile=$1/.gitattributes
  cat >$gitattributesFile <<EOF
###############################
#        Line Endings         #
###############################

# Set default behaviour to automatically normalize line endings:
* text=auto

# Force batch scripts to always use CRLF line endings so that if a repo is accessed
# in Windows via a file share from Linux, the scripts will work:
*.{cmd,[cC][mM][dD]} text eol=crlf
*.{bat,[bB][aA][tT]} text eol=crlf

# Force bash scripts to always use LF line endings so that if a repo is accessed
# in Unix via a file share from Windows, the scripts will work:
*.sh text eol=lf
EOF
  printf "\e[1;96m[STATUS]:\e[0m \e[3m.gitattributes\e[0m has been created. It sets git to normalize line endings.\n"
}

initGit() {
  projectDirectory=$1
  git init $projectDirectory >/dev/null
  printf "\e[1;96m[STATUS]:\e[0m Git repository has been initialized.\n"
}

showFinishMessage() {
  projectName=$1
  printf "\e[1;92m[SUCCESS]:\e[0m The project \e[3m$projectName\e[0m has been created successfully.\n"
}

showWelcomeMessage
verifyIfTreeExists
verifyIfGitExists
verifyIfTwoArguments $@

pathUntilProjectDirectory=$1
projectName=$2
projectDirectory=$1/$2
projectDirectory=$(echo $projectDirectory | sed 's/\/\//\//g')

verifyIfCorrectPath $pathUntilProjectDirectory
verifyIfCorrectName $projectName
verifyIfProjectDirectoryExists $projectDirectory
createProjectDirectory $projectDirectory
createFileStructure $projectDirectory $projectName
insertContentToMain $projectDirectory $projectName
insertContentToMainTest $projectDirectory $projectName
downloadPom $projectDirectory $projectName
setPom $projectDirectory $projectName
insertContentToReadme $projectDirectory $projectName
addGitignore $projectDirectory
addGitattributes $projectDirectory
initGit $projectDirectory
showFinishMessage $projectName
echo
