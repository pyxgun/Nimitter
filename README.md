# Nimitter
> Nimitter is a simple Twitter client that runs on the command line and written in Nim.

## Features

* Written in Nim
* View timeline, post a tweet, favorite/retweet
* Delete a own tweet or all tweets

## Install
### Requires

* Nim 1.4.2 or higher
* [CORDEA/oauth](https://github.com/CORDEA/oauth)

```bash
$ nimble install oauth
$ git clone https://github.com/pyxgun/Nimitter.git
```

### Compile
```bash
$ nim c -d:ssl nimitter.nim
```

## Set your information
Befor you run this program, you must set some information in `src/nimitterpkg/config.nim`.

* API Key
* API Secret
* Access Token Key
* Access Token Secret

These keys will be used for authorization your account.  
For that reason, you must get these key from [Twitter Developer](https://developer.twitter.com/en) at first.  

And also please set your twitter account information.

* Username
* Screen name

username is displayed name on your twitter profile.  
screen name is user id that begin @.  
For example, in case of Nimitter @nimitter, "Nimitter" is username, "nimitter" is screen name.

## Usage
When you run the program, your home timeline will be displayed and the program will be in the input waiting state.  

## Home Timeline
In this section, you can use the following command.  

* <kbd>1</kbd> or rl : Reload
* <kbd>2</kbd> or t : Tweet
* <kbd>3</kbd> or r : Reply
* <kbd>4</kbd> or f : Favorite(like)
* <kbd>5</kbd> or uf : Un-favorite(un-like)
* <kbd>6</kbd> or rt : Retweet
* <kbd>7</kbd> or urt : Un-retweet
* <kbd>8</kbd> or p : view own profile
* <kbd>9</kbd> or up: view other user profile

### Tweet
You can tweet text including line breaks.  
```
 --What's happening?
This is sample tweet (ENTER)
Use the Enter key to start a new line. (ENTER)
```
When you have finished writing, press <kbd>ctrl</kbd>+<kbd>D</kbd> to send tweet.  
And be sure to press the Enter key on the last line of the text you want to send before sending it.  
If you want to cancel tweet, press <kbd>ctrl</kbd>+<kbd>D</kbd> without typing anything.

### Reply
First, select the tweet you want to reply to.  
In the timeline, the user name is preceded by an index number. You can select a tweet by entering that number.  
```
[1]Nimitter@nimitter
  sample tweet 
  - date information

Which Tweet do you want to reply?
 > 1
 --Tweet your reply
```
Like this.  
The input method is the same as for Tweet.

### Favorite(Like)/Retweet
You can select a tweet by entering that number the same as for Reply.  
Un-favorite(Un-like)/Un-retweet are the same.

## Profile
If you select 8 or p in Home Timeline section, you can view your own profile.  
In this section, you can use the following command.

* <kbd>1</kbd> or <kbd>e</kbd> : Edit profile
* <kbd>2</kbd> or <kbd>d</kbd> : Delete a tweet
* <kbd>3</kbd> or <kbd>h</kbd> : Back to Home
* destroyall or DestroyAll: Delete all you tweet

### Edit profile
You can change some information of your account.

* Name(UserName)
* Bio
* Location
* URL

Select the item you want to change, and then enter the details of the change.  
Pressing <kbd>ctrl</kbd>+<kbd>C</kbd> keys will cancel the changes.

## Exit Nimitter
You can exit by pressing <kbd>ctrl</kbd>+<kbd>C</kbd>.
