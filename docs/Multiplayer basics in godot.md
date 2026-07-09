reference :  
[https://www.youtube.com/watch?v=tK2ACXUGcrY](https://www.youtube.com/watch?v=tK2ACXUGcrY)  
  
Uh over here I have um QR code for my YouTube tutorials. So if you guys want

to see more of me, you can check that out. Uh here are my itch games. If you

want to see past projects I've worked on, some of them are multiplayer, so it's good for inspiration. It sounds

like this is kind of working. I think it's Yeah, it's better a little bit. Yeah. Cool. Cool. Okay. Uh

this is the workshop repo which you all should probably have hopefully. And then this is a

this is another multiplayer repo. Uh it's a little bit more advanced. It's a

uh first person shooter deathmatch game and it has more advanced features if you

guys are curious like what uh what else you can do with this sort of multiplayer technology.

Okay. 245. So I'm Travis. I'm a software engineer. I've been using GDAU for about

three years. Uh these are all multiplayer games that

I've worked on. None of them are released. They're all prototypes, but

uh you can check them out. They should be all on my itch page or these two are YouTube videos. Um and they're kind of

relevant. So check them out if you want. Uh

over here on the left is a multiplayer game that I just did for the GDO Wild Jam. Uh it's a multiplayer car

demolition derby game. Um and that was pretty fun. I made that with Jonathan, my assistant over here. Uh he will help

if anyone gets stuck. And then up here on the top right, this is the advanced multiplayer repo that I was showing that

I said was like optional for you to download. Um, I decided not to do this for the workshop because there's a lot

that goes into a first-person shooter deathmatch game and we're going to stick with the basics, but this is all open

source if you guys want to check it out. So, okay. Uh, during the process when I was

learning how to do multiplayer, there are these um YouTube tutorials that were super helpful. This is by Devlog Logan.

Uh, really great one. and battery acid dev also has some videos that are super

helpful. Uh but also uh you are now in a room with people who care about

multiplayer games in GDAU. So definitely use each other for help and uh you know

lean on your community. So if you guys get stuck, feel free to reach out to me or your neighbors.

Um there are also two other multiplayer talks. One of them is by Chris. He's going to

talk about adding multiplayer to an already made single player game. And uh

there's another talk by James who is going to be talking about like more advanced networking stuff for

multiplayer and scalable solutions. Okay. So, our schedule is I made a

sample project. Um it looks kind of like this, but it's single player and we're going to add multiplayer to it. Um, and

we're all gonna follow along and it's gonna be great. And then once that's done, we can talk about more advanced stuff. That's optional. Uh, if you guys

have any questions, we can go over them. Uh, if you have any off-topic questions, if you could just write them down and

then we can hit them at the end, that'd be great. And, uh, hopefully by the end of this,

you'll have the confidence to start making multiplayer games. Uh, how many people can I get a raise of hands? How

many people have made a game in GDAU? Okay, sweet. How many people have made

multiplayer games? Okay, awesome. Good to know.

Um, this is the GDO docs, which is also super helpful. I'm sure you all are

familiar with this, but GDO has great documentation. Okay, what are we doing here today? Uh,

you all are familiar with Mario Kart. Mario Kart's mostly a local co-op split

screen game. That's not what we're doing. We're doing online multiplayer. So, you all are on two server computers

playing over a network. Could be local. It could be, you know, California and East Coast. Uh, that's what we're

focusing on today. How do you share a game over the network? Um, what we're going to set up

is a server and host. So, that's one person who says, "I'm going to host the game and then you all

are going to connect to me and join and I'll do all the management stuff." And then all the clients who join the

server, they're going to send their inputs and messages and stuff and the server is going to say, "Here's what the

game looks like. Also, make your computer look like this." So that's basically what we're going to set up

here. If anyone has questions or if I'm going too fast, definitely let me know.

Cool. All right. Uh, we are now going to add multiplayer to the sample repo.

So, does everyone have that up? I got a couple errors about plugins when

I uh what what error are we talking about?

There is one plugin that I included. It's called the tile instances add-on.

Um it's by someone and it basically lets

you run uh two instances of the game but side by side. Just a little helper.

Yes. So same dialogic.

Oh yeah. Should be no dialogic. You're right. And as a bonus, uh this workshop is

probably like less than a 100 lines of code. So that's that's pretty sweet, right?

Okay. I did the wrong one. Sorry. Oh yeah, no worries. No worries. Okay,

so here we go. Uh everyone has the game open, right? Cool. Okay, so if you run

it, you'll see something that looks like this. You can move with wedd w

and um that's about it pretty much.

Uh okay. So this is a single player game. We're going to make it multiplayer.

Um if anyone gets lost, I have instructions step by step in uh this

GitHub repo for the workshop. If you look at the read me, it's right here.

So, I'm going to also follow along this and we're going to do that. Uh, so one thing that is interesting with

multiplayer is personally I usually have my player as a part of the level when I make games because, you know, it's like

a child of the level. Uh, since we're doing multiplayer, we're going to have lots of players. Um, I keep the players

separate. So, I put my players in the players manager node and then they just exist in the level separately.

Okay. So, first we're going to set up testing locally on your one computer because, you know, we're building

software that's going to run on multiple computers, but right now we only have one, so we're going to test it locally.

Um, if you go up to debug

and customize run instances in the top left,

you can set up your GDAU editor to run two instances of your game. So you have

to check this box here, multiple instances and add two.

And then the next time you press run, actually you first have to go to the

game tab and uncheck embed on next play.

And that will make it so that uh the game runs kind of in the pre4.4 way.

and then it will run the game twice and that is helpful.

What are we uh unchecking? So in the game tab, if you go to these three dots here,

okay, you can disable embedding the game.

And uh the tile instances add-on is in this repo and that lets it uh spawn the

two windows side by side. And that's that's helpful when you're prototyping

because otherwise you have to move it every single time and it gets really annoying. What's that?

Uh are you on 4.4?

Uh I guess you could try running the Oh yeah. Okay.

All right. So, we can now run the game. Uh, two instances of it, but they're still both single player.

So, let's now figure out how to connect computers over the network.

So, we're going to set up a hosting client relationship. Um, we're going to use this thing called ENET. ENET is a

library that provides reliable UDP networking. And GDAU has highlevel rappers for the ENET library which is

available uh you can see the docs for it. I have a link for that. So that's

cool. Reliable. Reliable UDP. That's a great question.

Um I don't know too much about ENET. Apparently this best bin is it. Uh but

that's what it says it is. So somehow that works. Uh basically UDP

works as like in UDP there's not really a way for you to say like oh I know that

you got my message. In UDP you just kind of send it. I assume that ENET has some

sort of way to send like acknowledgements or something but I don't know too much about it.

I think I think at the base it's UDP and then they have some sort of like act uh what

is it synac for TCP on top of that but I think it's only UDP

because you can you can switch between unreliable for some unreliable. So they

built a little a little handshake on top.

Yeah. So there there are reliable options or you can do just raw unreliable messages.

Yeah. Okay. So we're going to set that up. Um

let's do that. Let's create that. So in the gametree.tscn

um does everyone know where that is? It is in components in the file system.

Can everyone see this? All right, too. Is that good? Yeah. Okay. Uh, we're going to add a node here.

Um, and I'm going to call it server interface.

And then we're going to add two nodes underneath this.

And one of them is going to be called ENET server

and the other one will be called server connector.

This is just like a nice way to organize our server code. Um so it's very clean and organized.

Uh these two nodes, the ENET server node is going to be responsible for creating an ENET server. And the server connector

node is going to be responsible for joining an existing server.

Okay, let's attach a script to the ENET server node. You right click, attach script, and we

can just call it ENET server. I like to give my scripts class names.

I'm just going to call this one en server as well.

And let me look at my finished project.

So in the finished uh completed branch, um oh sorry, yeah, I should mention this. So right now we're on the main

branch which has no multiplayer, but I also made a branch on this repo called

finished product and that has multiplayer finished in it. So if you get lost or you need to reference that,

you can look there. Anyways, we're going to make a function called

start server.

And in this function, we're going to create a new variable called network.

And we're going to create a new ENET multiplayer pier. And this is going to allow us to use the multiplayer API to

interact with our survey that we're creating. Where does that object come from? Is it just built into

Uh yeah, that's built into GDAU. Um here's the docs for it. Uh

And then on this newly created network uh variable, we're going to call the start

uh or no create server function.

And we're going to have to pass in a port as well as the number of max players.

And while we're at it, let's also add input arguments to this function. So

when we call start server, we're going to call it with a port which is an integer and the number of

max players which is also an integer.

So what this function does is it creates a pier and then it says this pier is going to be a server. So it calls the

create server function on that pier and that's how you create a server in uh two lines of code. Pretty sweet.

But we also want to store this and we can store this in our multiplayer singleton which is accessible by any

node in GDAU. So we're just going to type multiplayer

multiplayer appear and set that equal to our newly created network

and that way we can uh reference that later if we need to. The multiplayer singleton is that a

pre-built singleton? Yeah. So that's part of uh I guess the engine it's

accessible from I believe this is just the node class

right here. Um

and yeah so it uh it's just a singleton um I guess it's like a global way to

access the multiplayer API.

Cool. So now we have a function for uh starting a server.

Let's add a script to the server connector.

And uh we're going to create a function called uh connect to server.

And for this one, we're going to pass in a host IP,

which is a string, and the port, which is also an integer.

And we're going to do something very similar when we created the server. We're going to make an ENET multiplayer

pier.

But this time we will call the create client function on it and we'll pass in

the host IP and the port.

We will also store this in the multiplayer singleton.

And I'm also going to add some print statements here.

So, how this is going to work is when the player who says, "Hey, I'm going to host the server." They're going to

completely ignore this server connector node, they're not going to touch it at all. They're only going to use the ENET

server node and call the start server on it. And then for all the clients who are

going to join that host, they're going to completely ignore the ENET server node and they're just going to look at

this server connector node because they're the one connecting to the server. Does that make sense?

Cool. I have a question. Yeah. Um, in both the connector and the

server, you're setting multiplayer multiplayer P2. Yep. Are they not overwriting each other? So

the reason they don't overwrite each other is because server connector is

only going to be called by clients and um ENET server is only going to be

called by the host and since they're on separate computers uh

separate singleton yeah separate singletons. That's a good question.

Okay.

Uh, also, um, if you do want to do this on the network, you will probably have

to port forward um, if you want people from other IPs to

connect to you. So, that is something to consider.

Okay.

Is that in your advanced one? Uh, is what in there?

Port forwarding. Um, so port forwarding is a thing you have to do on your router, on your

network router. And that just pretty much like opens it up so that you can say like I'm okay with people connecting

to me on this port. So, it's not entirely cyber secure.

Something to consider, but it's not something we have to Yeah. Yeah. The game is unaffected by

that. And since you're on your local machine, you don't have to worry about it because you're already connected to yourself kind of.

Okay. Um, we're also going to on the server connector,

we're going to listen for when the multiplayer singleton emits a signal.

And that signal is connected to server.

So we're going to connect that to a function we're defining right now.

Uh this signal has no input parameters.

Okay. So, yeah, we're going to listen for when the multiplayer singleton says, "Hey, you're connected to a server." And then

when we are connected, we're just going to print out, "Hey, you got connected." Very cool.

Then our next step is we're going to create a script for the game tree which

is going to connect uh our UI front end to uh the server connector and the ENET

server starter. So if you just add a script to the game tree and call it game tree.

Okay, let's get a reference to our start connect menu. So if you

uh if you click and then hold control and drag it in,

you can get a reference to it. like that.

And we'll also create a ready function.

And we also want to get references to our ENET server and server connector.

Grab both of them.

start. Okay. So now we have references to the the guey front end um or the connect

menu and then our two network nodes that we created. Uh and let's connect signals coming from

the start connect menu. So there's a signal called guey

or what what are the signals called?

Oh, not what I thought it was called.

Oh, wait. I wanted the guey manager. Yeah, let's get a reference to Guey

manager instead. Sorry, guys.

Just from here. There we go. So now we have a reference to the guey

manager and the two server nodes. We can connect from the signal coming from the guey manager.

That's going to take me a lot of hold it down. Right. The click and drag.

Yeah. Yeah. I always learn cool stuff watching other people. Start dragging

how you were trying it without it and then and then press it before you drop it

on the

Okay, so we are going to connect um the signal from the guey that says I'm the

guey and I want to host a game and we're going to connect it to our ENET server start server function that we just

wrote. And now whenever you press the host game button on the connection menu,

it'll start a server using those uh settings.

And we're also going to do that for joining the game.

Same deal. Oh, I I had it. Oh,

okay. I think that's everything we need for our first test. Uh if you run the game

and then walk over to the start menu because that's the thing you have to do

uh and you press host on one computer, you'll get an error.

Yeah, no problem. There might be a bug in it. Um so let's

all take a look. See, start menu host game. Oh, sorry, my bad.

Oh, my bad again. You have to pass parameters to start server.

Is that what it is?

Oh, I do. Wait, no, that's right. Right.

Oh. All right. Yeah, let's get rid of that max players then. And we'll create a

local variable called max players.

We'll set it to like 16. That's probably what the error is.

I'm also going to put a print statement here so I can just see uh starting server on port.

Okay. Is ENS server good for you? Yeah. Yeah. Sweet. Okay. So, if we press play

now, everything should hopefully be connected. If we waddle over to the start menu,

uh you'll see that the host on the left, I just clicked the host button.

And in the console, it printed that we're starting the server. And then on the right, I hit the join button. And it

says uh connecting to [localhost](http://localhost) and connected to server.

Does everyone see connected to server on their machine?

Yep. Here's our game tree.

You open the server script again. Yeah.

Should I give a game?

And then server connector. That's right. This is about the most code we're writing. So, we're almost

done.

It is pretty sweet. Yeah, when I was learning Unity, I was like, how do I how do I do this? Like

that was tough.

Yeah. Are we good with server? Yeah.

favorite connector it is. Uh

trying to see if I'm missing something.

Yep. So you make a new pier. Uh you call the create client function on it. Uh, we store it in the singleton

and then we just connect to listen to when the multiplayer singleton says that we've connected

and I just print out you're connected to the server. Well, everything I pretty much

could tell you I found out

Okay. How's everyone doing? Thumbs up.

Uh yeah. So the signals from guey manager uh they just pass in the host uh IP and

port from that menu that I made.

And also uh so everyone knows local host is the IP host name of your own machine.

So when I when I say that you're connecting to local host Oh, it's basically just saying connect to

your own computer. That's fine. Is it expected that the chat

toggle editing toggled to comment out? That might be my fault.

Uh 93%. We'll fix that later. Yeah,

he'll take a look too. Oh. Uh if you get rid of the parenthesis

in the connection. Yeah. So you just want one to close it.

Oh, I see. Yeah. Unless that should hopefully It just

lines over the battery. The computer goes in a fetal position. The battery is just like

sweet. What's going on? My computer

saying portals.

Oh, the buttons. Yes. uh

for the client.

That might be different. Yeah, that's right. We'll figure it out. Yeah, we'll get there.

I'm not sure. All right. Uh, cool. So, I think everyone can now say that they've created a server and they

can connect to it. Oh, that's um next we're going to spawn players for the clients. Yeah, I think I changed it.

So, uh, GDO has a multiplayer spawner node that we're going to use for this,

and that lets us spawn nodes, um, in the scene tree, and it allows you to spawn

them across all the connected clients. So, let's add one of those, um, in our

game tree. Let's control A and add a multiplayer spawner.

This is just a built-in node in GDAU instead of

And you'll see in the inspector we have a spawn path variable.

Um, and I'm going to select my players manager node as where I'm going to spawn

the players. Yeah. Yep.

changes. So, we select players manager

and in this auto spawn list, we have to define the scenes that we're allowed to

spawn using the multiplayer spawner. Okay, a lot of spawn.

Um, so if you just uh drop that down, add an element,

um, then you can select entities uh player.tscn tscn

and that will allow us to spawn the player.tscn using the multiplayer spawner.

Okay, now we have to add a script to our players manager node.

So let's add a script. Call it players manager.

And we're going to give it a ready function.

And what we're going to do here is we're going to listen for the multiplayer um pure connected signals.

So when a pier connects to the server or to the client uh this signal will be

emitted and that's how we'll know when to spawn players. So we're going to connect this signal to a on pure

connected function which we will now define.

We also need to uh in the file system if you type in player you'll find the

player scene and then if you just click and control drag it into here we can get

a reference to that scene and that is what we'll instantiate for each of the players.

So we say create a variable for the player

which is just the player scene instantiated. We'll add that as a child.

And one thing we're going to do is we're going to set the name of this player node

to be the peer ID. So, every time that uh a client joins

the server, they're going to get a unique pure ID, and that's how we can tell like who's who pretty much.

Um, and it's important that we set the name of the player node to be that pure ID, so we can keep track of who's

controlling what player.

Okay, I think we're good to test it. Oh, wait. We still have a player in the players

manager already. So, we just want to get rid of that guy. So, you can delete that node.

I have a quick question. Yeah, in the multiplayer spawner, um, we had the spawn path pointing to the player

manager. Yep. Um, however, we are manually adding it to add child.

Yeah, that's a great question. Um, so as far as my understanding is, the

multiplayer spawner uh just facilitates um replicating nodes

from the server to all the other clients. Um, but it is kind of weird that you still

have to instantiate and add a child. Uh, it doesn't do that automatically for you.

So,

That's probably what's happening.

Oh, yeah. When I saw that happen. Not only that, but

Yeah. So, we can test that right now. Um, so now we have no player and the start

menu is where it belongs. Um, if I press host, you'll notice nothing happens.

But if I press join, you'll see a player spawn.

So, what's going on here? Um, the host did not get a player. The client did get

a player. You're totally right. Uh so pure

connected is not emitted for the host because the host is already there

and since the host is like not connecting to itself there's no pure connected signal that

comes out of the multiplayer API. So that's why the host didn't have a

player. And what's happening on the right here is the client is actually seeing that

the client connected with appear connected but also that the host is connected. So there's actually two

players underneath here. And we can verify that by checking out

the the remote scene tree over here. Uh if you press that

um so we'll see this is the host. You can't really tell from here but this is

the host because there's only one player and that is a client. But if we down here you see there's uh

the two sessions, session one and session two. If you switch between them,

it will switch the scene tree that you're looking at.

And now you'll see that there's two players here. And this is the client's one only

because I know that. Um, you can't tell it, but that's what it is. And you'll

see one is the host player and one is the client's player.

So to recap, The host player invisible.

The host doesn't have a player on the host's machine, but it does on the client's machine.

They're perfectly stacked because they spawn on top of each other and the inputs are controlling both the host and

the client.

No, there would just be three players on top of each other.

We'll fix this in a second and hopefully it'll make more sense. Um, but yeah, this is kind of confusing

and it was very confusing for me when I was learning this. I was like, where is my player?

Just make sure you said the client only has their character on their screen.

So, actually, you would you would think that, but it's the opposite. Um, the client sees

this is the client scene tree, and you can see there's two players in it. So, the client sees the host's player

and their own player. Okay. But the host doesn't see their own player, right? Yeah.

Okay. So, we got to fix this. Um, let's start by creating a player for the host.

So, since this peer connected is not going to be emitted for the host when they're hosting

because they're connecting to themselves, you're not going to get a signal saying, "Hey, there's a peer connected to you. It's yourself."

Does that make sense? Okay. So, yeah, we have to figure this out manually. So, what we're going to do

is uh if we go back to ENET server,

we're going to create a signal called spawn player for host.

And we're going to emit this signal

when we start the server.

Then if we go to the game tree, uh we need a reference to our players

manager. Let's drag that in.

And then we will connect uh the signal from ENET server,

the spawn player for host signal from that. We're going to connect it to the players manager.

And then we're going to create a new function called spawn player for host

inside of the players manager.

Okay, inside of players manager, we're going to define that function that

we just created. It'll take in no parameters. And what

we'll do here is we'll just say onper connected

and we'll pass in a one. And the reason we're passing in one is because one is the ID of the server

always. All the clients will have like random long numbers. Server is only one.

Is that hardcoded? That Yeah, that's that's just how it works by default. Um server number one.

Okay, if we run the game now, we will see that

the host will have a player. And if we move that player a little bit and then

we join on the other side, we'll see that a player is created for the client.

But on the client screen, they're still on top of each other. And on the host screen, you're still controlling both

players. So that's one more thing we have to fix. But that's an improvement.

You got an error. Oh yes. Uh I'm supposed to mention this.

Um you will receive this error called uh onspawn receive condition parent has

node something. I have no idea what that means. You can ignore it.

Yeah, I think it's something to do with the multiplayer spawner. What triggers? I think when you spawn players, uh, this

this red node, uh, parent has node error shows up.

But as far as I know, we can ignore it. So should be okay.

Yeah.

What is the castle door doing? the multiplayer instance.

Oh, that is because uh you'll see that if you

so I snuck a little bit of multiplayer code in the castle door just so this will go faster. But basically what'll

happen is um you started running the game, you connected the host and the client and then once you disconnect one

of them uh it'll be like oh I was connected to the host but now the host

isn't there anymore and that's what that error is saying. Yeah. So you can ignore it.

Okay. So we've solved our problem with the host not having a player.

Let's see what's next on the to-do list.

Okay.

If you close the host. Yeah, that makes sense. Okay. So, you'll notice at this point when you

control any player, it controls all players. And it doesn't really seem like it's multiplayer. Seems like you're just

playing single player with two people. So, we're going to fix that by assigning multiplayer authority.

Let's do that. Um

so what we want to do is when we spawn players we want to assign the authority to them. So authority is basically

saying like who is allowed to control this player? You know is the host allowed to control it? Is client number

one allowed to control it? Is client number two allowed to control it? We're going to say that.

right now. Um, one thing I like to do though

is I like to keep that code separate because normally you would put it in the player script,

but I like my players to focus only on the player. I don't think the players really need to focus too much on assigning authority and stuff. So, I'm

going to create in the components folder in the file system. If you right click and create new scene, we're just going

to create a blank node scene. And we're going to call it multiplayer_client

as thetsn scene name. Yeah. The gooey manager.

And this is kind of optional, but I like to do it because it makes the code cleaner.

So you all will do it too. Um, so now that we have a multiplayer

client node, we can save it. That's fine. And we'll attach a script to that.

Call it multiplayer [client.gd](http://client.gd). And in here

in the enter tree function, which is a built-in function that runs

whenever a node joins the tree.

Um check on the GitHub.

You can check the the branch. So when this multiplayer client node

enters the tree, we're going to get the pure ID from that node's name. And you'll remember when we

spawn our player, we set the name of that node to the pure ID.

So we can get the name of that, parse out the ID of it, and then we'll

we'll call this built-in function called set multiplayer authority on that pure

ID. And what that does is it says this node

and anything under it belongs to that one pier.

connected when we instantiate a player.

I don't know. We could possibly do that. Yeah, that might be a a better way to do

it actually.

Yeah, you probably could if you did it in here.

I know. I'll try the next one. That might save some complexity,

but anyways, we're already too deep. Um, so yeah, this is everything you need for multiplayer client. Does everyone have

that? Sweet.

Great question. So, what we're going to do here is we're going to uh control A

or no control shift A and we're going to add the player as a

child scene of this client. And what happens here is when we call

set multiplayer authority on the client since the player is a child of that by

default set multiplayer authority recursively sets the authority

to all the child nodes.

So the that player will also have this called on it. Does that make sense?

Yes, exactly. So, our next step is we'll go back to the game tree. We'll

go back to our multiplayer spawner. We're going to leave the spawn path the same, but we're going to change this

element instead from being the player.tscn to

being uh component multiplayerclient.tscn.

So, instead of having the player up here, we're just going to spawn the client instead.

Cool. Let's see if that worked.

And we probably won't see much of a difference because we haven't ran the rest of the code yet. But

no error, so that's good. Cool.

Sorry, what did you set as the spawn path? Yeah. Uh, spawn path remains the same for players manager. We're going to add

our players as a child of players manager. And then in the auto spawn list,

we had player.tscn here. We're going to change that to multiplayer client.tscn.

All righty. So, if you run the game, you'll notice that uh you're still controlling both

players. So, what we have to do now is we go to our player scene.

Here's our player scene. Uh I have all my player logic in the player controller node.

And if we go in here, this is where the inputs get handled.

What we want to do to make sure that we're obeying the authority

is we want to say if not is multiplayer authority

return.

And that way when we get to this point and if we're if we don't own this player

then we just don't do any calculations for input. We don't do any calculations for movement. We just get out of there.

But if we do own that player, then we do all that.

All righty. So once we make that change, uh, we should notice

we can't move the player. We can't move the client. I still have

Oh, I see. Yeah, that's weird. All right, let's figure that out. Um,

I don't see any errors other than a warning unrelated.

If not, is multiplayer return.

So in the remote scene tree, you can see what the authority is. It's actually one of the first things it shows you up

here. It says multiplayer authority is one. So on our player node named one, we have

multiplayer authority of one. And on player node

uh three, we also have multiplayer authority one. So something didn't work.

Let me check my notes.

Oh, I forgot. My bad. All right, let's go to gametree. And if we go into

players [manager.gd](http://manager.gd), we were previously spawning the player

scene. We now need to change this to be spawning or instantiating the

multiplayer client. Yes, that's the part I forgot. So, let's change that now.

Comment out player.

And instead of player, we'll do multiplayer client.

Multiplayer spawner. Do you know that's what we're spawning? you would want it to figure that out.

It's just you want it to be. Is there a I guess the question is, is there a time you want different?

Um, so in your multiplayer spawner in this auto spawn list, if you want to get

crazy, you can also spawn other things other than just players. Like, uh, I made a game where you were spawning like

laser blasts that like move slowly. Uh, so I was using that in here. And I guess

that's a variable amount and you want to be able to specify which ind. Yeah. So you kind of want to specify

which of these

scroll down.

That worked. That works. Awesome.

How's everyone doing? Uh, could you go back to the multiplayer client scene real quick? I feel like I missed

something. Yeah, here is multiplayer client. It's just a node.

There's a player and it has a child that's a player. Yeah.

Yeah. Yeah, let me take a look.

Okay. Smart player, you know. Oh, um, you want to Yeah. Here, let me

let me pull up that uh let me pull up um game tree actually. So

I think what you're missing here is uh en server emits a signal spawn for

spawn player for host and then you want to connect that to the players manager.

Yeah.

Did you say something about Oh the GD? Yeah, I do that too.

Yeah.

I hope everything has made sense so far.

It this isn't like black magic. Okay.

My my goal is that everyone can go home and uh actually use this. So I hope everyone understands.

Yep. So, yeah, we have the signal up here,

spawn player for host, and then it gets emit when you start the server. Yeah.

Okay.

Okay,

I think everything's working right.

Okay, so if you run the game now, you'll see that you can control your own player and

not the other person's player, which is good. Uh you'll notice that it still does not

match left and right. And on the client, you'll notice that uh we're not looking

at your client, we're looking at the host. So we got to figure that out, too. So let's fix that first.

If we go to our player scene, basically what's happening is the camera

of the host is being made current instead of the player of your client.

So if you find the camera 2D on the player scene and you drag a reference in

for that

then in the ready function of the player you can say if not is multiplayer

authority we'll just delete everyone else's

camera. Uh this is [playercontroller.gg](http://playercontroller.gg)

actually we do and we also want to return for deleting that.

So basically on every player we run through this ready function when we spawn it we say do I have control of

this? If I do have control of this player, this is my player, then skip this, do all that. But if it's someone

else's player, we don't want to have a camera on them. Or you could just disable a camera or something. But let's

just delete it for now.

Why not? Oh, really?

The name is passed throughver.

[Music]

Oh, right. Custom spawning. I see what you're Okay.

Yes. That makes sense. Sorry.

Yep. So, this is just the player controller script. Um,

camera 2D is a reference that I dragged in. One of the on ready references.

It's right here.

If you just click and drag it, it should uh add the reference for you.

Are you returning from here? Also, I I put that block of code in.

Oh, okay. Sweet. Okay. Um, so now we can as clients look

at our own player, which is awesome. Um,

and I think that is everything for step three.

What's that? Yes. So, if if this is your player, you

don't delete the camera. But if it's anyone else's player, you say, "Yeah, just get rid of the camera

because I don't want to look at them. I just want to look at me."

Uh, the reason I return here is only because um chat UI is a child of the

camera and I have some code doing chat UI, which actually I guess you don't need to return because I check for it as

null, but Yeah.

Yeah.

Oh, yeah. Expect the two arguments for called the one.

Can you go to Oh, start server. Yeah. If you go to en server

uh GD right there. Yep. Did you get rid of this max players? That was a That was a mistake.

Yeah. And then um You just get rid of max players, too. The default 64, so it should work.

Okay. So, this is almost looking like a multiplayer game.

I can try

Sorry.

Cool. So, step four of my readme is synchronizing movement, which is what we're about to do. So, let's do it. Uh,

GDAU also, similar to the multiplayer spawner node, there's a multiplayer synchronizer node.

And what that does is it synchronizes variables across the network. So like floats, integers, vector 3es, pretty

much whatever you want. Um, you can synchronize across the network.

So in order to synchronize our player's movement, we're going to shift A and uh

add a child multiplayer synchronizer node to the player.

So, when you add a multiplayer synchronizer node, you'll see down in the bottom here, there's a new

replication tab on the bottom of your editor.

In there, you can press the add property to sync button.

And this allows you to pick a node that you want to synchronize. And then if you double click on player

which is the character body 2D you'll see all the properties that you can synchronize.

If we just type in uh position which is a node 2D property

you can double click position and we will start syncing the position.

You'll see I have a million errors because I'm still running the game and it does not like that.

So we'll get rid of that. Yeah.

So, it'll say what node you're syncing, what property you're syncing, uh, I don't know what that means, and

then how often to replicate it. I think spawn is just like sync it once when it spawns, but since we're syncing

it always, doesn't really matter. Okay. So, if you're on the game now,

post and join. That's multiplayer right there.

Let's go. Okay, so that's pretty sweet. Um,

if you have that working, you have multiplayer working. Pretty

sweet. Uh you'll see there's still a lot of stuff that uh you can't synchron or

isn't synchronized. Uh but we can add that easily. But basically the whole point of this

demo is uh you need a friend to help you stand on a button to open this door. And

uh once you both stand on the buttons, you can both enter the castle and get

the loot. And all is well except the doors closed on the client. So we have to synchronize

that. Uh the buttons don't move, the torches don't light. So that's all stuff

that uh you can use multiplayer synchronizer for. Um we can do the castle door since we

have time. So, if you had a multiplayer synchronizer to the castle door,

I'm using an animation player to move the position and rotation of the castle

door's static body 2D. So, we're going to want to synchronize

the static body 2D. We're going to want to synchronize the position of it

as well as the rotation.

and we'll synchronize them always. And like usual, I have a million errors because I changed this while I'm running

the game, but that's okay.

That's a great question. Um, so

the reason that it doesn't light on the client side is because I went ahead and

in the sample repo I added a little bit of multiplayer code right here. Uh, just so that you guys

wouldn't have to. Um, I added this if not is multiplayer authority return to

the castle door. And I think also on the button and the button is what triggers the torch.

So what happens on the client is if I pull up the client which is not running.

So my client's on the right here. If I stand on the button, the button does nothing. And normally it should do

something because we didn't add any code, but I did add code to it. So, if we look at the button script, the stand

on button, uh, basically there's an area 2D

that detects if someone's standing on it. And I have it connected to this on body

entered, but I have this if is not the

multiplayer authority, then do not do anything. And that is this is what

triggers the torch uh and the door. So

because the client is not the authority, I can't do that. Is there why why add that?

Why add that? Great question. So

basically what we want is the host is the one who knows the game state, right?

So, basically how multiplayer works is we're all agreeing that we're seeing the same things, but it's the host that does

like the actual like this is the truth. Everyone else replicate me. So, instead

of doing like the area 3D calculation here on all the clients and stuff,

I only do it on the host. And that way, what the host sees is true.

And so, that's what this check is for. would you just add a multiplayer

synchronizer on everything? Yeah,

I guess so. Yeah, I mean I was going to ask how expensive that gets like is there a stopping point you think or

Yeah, I mean so there are certain things you can do on every client that's not going to impact it,

right? But like for important things like um

I don't know. I guess like let's say this button's really important.

You want it so that the host is the one who's deciding if that button is getting pressed, right? Instead of any client, you know,

and if you're using a dedicated server, the server would decide and they would just use to do that.

Yes, the the server would decide. So, like on clients, there's a lot you

can get away with with just being like, "Okay, you're a client. I don't really care about like graphics or like how

nice your game looks or like I don't know. Maybe even if there's some NPCs, it's like all right, like they're very

low low-key NPCs, like you can figure that out on your own." But like for important stuff,

I would even say like if like you're in an FPS shooter and you say like, "Oh, I'm going to shoot someone."

You can't just be like, "Oh, I'm across the map and I'm gonna shoot someone." Oh, I see. And be like, "Hey, I just shot them."

It's like, you kind of want the host to be like, "All right, like you're within range. I can see on my game

with all my data that you're able to shoot them." Stuff like that, you know?

But it's really up to you on how you want to handle it.

Um, let's look at that. Let's look at that. So, uh, what we did was for the castle

door, we added a synchronizer and we're synchronizing the position and rotation

always. And so, every network frame, which I believe is 30 times a second by

default. Uh, don't quote me on that.

But every network frame, we're syncing the position of this castle door and the rotation of this castle door

along with the position of each player. Well, now it is because I closed the host. Oh, I see.

If we test this, we'll see that it works. And that's great.

If we go to the debugger and we go to the network profiler,

which is this setting over here, we can turn on the network profiler,

and it will start profiling all the data that you're sending on the network.

So, you'll see over here we have a down and up. Uh, I'm gonna say this is the server,

but if you switch sessions, it'll be different. Um,

you got to start this one, too. But anyways, you'll see how much data

you're sending up and down to from the server. Uh, and you can see that we're sending

1.3 kibbytes per second and we're receiving 2.9 kibbytes per second. A

kibby bite is 1,00 bytes and 24. Okay.

Cool. Yeah. What Duke said um,

yeah, I think I just had it backwards. Yeah. Yeah. It's all right. It's close enough.

Anyways, so uh the question is

are multiplayer synchronizers efficient? And depends on how you use them. So we

don't really need to sync the position of this door every single frame, right? Because it only moves once.

So, what you could do is um if you go to the castle door synchronizer,

you can change the replication settings from always to onchange

and then it will only say, hey, I'm a door and I just moved. That's that's my

update, right? But if the door doesn't move, then it's like, don't worry about me. I'm not moving. You know, is

there a reason you wouldn't want it to always be on change?

Is there a reason you wouldn't always wanted to be on change? Yes. Um,

so it's kind of uh I think I think Jonathan and I were doing like some Reddit research or whatever, which is

the best research, but uh I think it seems that uh when you say onchange,

there's like a acknowledgement portion in the network. So it's like I changed,

tell me that you saw that I changed and I'll say okay, cool. So it's just like added on messages.

So if you need something to be extra responsive. Yeah. So I love to do my players always

and then anything that like changes a little bit every once in a while I do on change.

Um so uh when I was asking about like expensiveness I I was more asking like

how scalable is this solution? Should like the more players the max players here is 16. Is this like a good way to

set it up for 16 players to just have like all everything track all the time? How much would it be dependent on host

realistically? Uh the question is is this efficient for

large amounts of players? Yeah. Yeah. Oh, okay. That's fair. That's fair.

Um premature optimization is the root of all evil. Uh I don't know. I think it

would be. Um, there's probably some solution like if you have like a big MMO game, there's probably a way for you to

say like if you're not close to each other, then don't synchronize to each other and maybe have like local

if you're close to a player, you can actually see their updates. But if you're not

public visibility, yeah, it's just a property of

So, Oh, okay.

Huh. So, on the multiplayer synchronizer, there's a public visibility

variable that you can toggle, which I have never played with, but that

seems like it'd be perfect for large MMO games or something like that.

Cool. So, speaking of premature optimization, yes. Yes. Your goal is to use steam and the

steam is epoxy. You will quickly find that you are 12

very low bit rate and sharing position every network frame

either you have to make your network frame so slow that it looks horrible or

in that case you want to share position velocity and then do an animation where

you expect and optimizations like

cutting that are too far to matter. Having a back end sort of thing like for the door

we could just have one function that's like doing the door instead of sending

all of the updates by Yeah. have to optimize it on

Yeah. So what Duke is saying is if you ever do go with like uh GDO Steam is it

called uh what is it? There's more of a network limitation you say? Yeah.

Okay. Yeah. So, um there's ways you can optimize it. Like for a door animation, instead of synchronizing the rotation

position on change, what you could instead do is uh just send a boolean

that says like door is open. And then once you see that that changes, you play like an animation on the client side as

well. So you'll essentially start the animation at the same time, but you're

not sending all the key frames over it. You're just saying like start the animation and then each client will

figure out like oh the doors opening I'll play that animation. I know the rotations of that. So you can do that.

Um if you're really interested in optimizing a little bit more, I have a

script. It's a little bit further down in the readme, but I call it my net position lurper.

And basically uh it just lurps between the positions of

the players. So uh what you can do is you can send your

position less frequently and that reduces the bandwidth that you're using and then you just lurp interpolate

between each position that you receive. So as you see other players you say okay

he was there now he's there. I'm going to alert between them smoothly and

that'll also help reduce bandwidth. Um, and this is the code for it.

Yeah. Yeah. So, you can you can run uh you can

host this in headless mode. Uh probably what you would do is

you can set like a custom uh argument for launching the game. Usually

it's like d- headless and then you would like I don't know somehow I think can compile

for headless. So you like do a headless build. There's ways to do it.

Yeah. Cool.

Yeah.

Oh, yeah. Yeah. Great question. Um, so that my net position lurper is using the multiplayer synchronizer,

but you'll see here and the replication interval, you can reduce how often

you're replicating this. So you can do like every 0.1 second or

every like one second. Um if we do every one second it's pretty

choppy but um if you were to lurp between them

it might look better. So I basically just send like every one

second and then uh perfect. But if you lur between it, it's

like kind of okay, you know, just a thousand pigs. What's that?

How do you make it? Oh, uh, every physics frame.

Oh. Um,

I I think I think so. So, um I put this note on my player, right?

Hook it up and then um every physics frame, if I'm not the authority, if this is data coming in from other people,

then I will lurp them to where they are. Um

and otherwise host will update.

Yeah. Yes. Yeah, that makes sense.

I just want to interrupt real quick with just a time check for y'all. If if you need a break, you're about halfway through. If you don't, welcome to keep

Oh, we're halfway right now. Uh rough. It's like four o'clock. So, sweet. I think we're making great time. This is awesome.

Just wanted to make sure. Seems like everyone's like head down and focused in both rooms. So, we're just springing in to remind you guys you're welcome to

take a break. Awesome. Does the synchronizer get rid of the idea of like tick rate like server side

tick rate? Is that just abstracted away? Tick rate. Yeah. Um is that something that is like

configurable? tick rate. Like typically a server would have like

like a a dedicated server game would have like a tick rate that like controls

like what's the fastest update that's possible.

Yeah. Yeah, you could probably set that. Yeah, you could probably change.

Okay, I'm sure there's a way

to I think. Yeah. Yeah. I think somewhere in the docs it

says like how often a network frame is. Yeah. Okay. You could probably toggle that or like

increase it or something. That's an issue. But then there

you had a question. That was one of the things you talked about. Oh, sorry. Yeah. Um, I want to worry

about the player knows dictionary right now. Gotcha.

You don't see um what do you not see?

Uh, excuse me. So, um, this hasn't really been an intrusive issue, but I just figured I'd

ask my third wheel guy shows up.

Yeah.

Can you um if you I would check in the remote tree

and um Oh, yeah. Are are you spawning for

it? Um is it connected in the game?

Yeah.

Um, I'll send Jonathan.

What's up?

That was only

easier. Like I mean in order to handle animations across the

network. How do we do that?

So sometimes I do it based on velocity or something. Um, so I kind of like calculate the

velocity between frames and do based on that. You could probably synchronize like an enumeration for like

animation like animation state enumeration. I think you can synchronize that. You

can also synchronize animation player also animation tree variables.

Yeah. So I I'll probably just do that on change. Yeah.

default. There's a lot of ways. Yeah. Uh okay.

Oh, so uh one thing that I want to point out is um

it's very important that you have like anything that you're syncing has to be at the same path on both

the host and the client. Um So you'll see here in this example

uh the host player is at rootgametree/players manager one

and that has a synchronizer on it that's synchronizing stuff that multiplayer synchronizer is looking

at that path and saying that the node at this path has this property

and it's changing like this. So that has to match.

Uh where you run into issues is if you spawn things at runtime. If anyone spawn like a bunch of rigid bodies or

something, you'll notice that uh the first one will be like rigid body 3D and then the second, third, fourth is

like rigid body at like some random number. That'll give you trouble.

Uh if you're trying to synchronize those. So I think a way around it is if you can

like somehow generate a unique name. Kind of like how the pure ID is like a unique name.

scroll. That's kind of one way to get around it. I still haven't figured it out, but that is an issue we'll run into

if you're trying to spawn things at runtime that are synchronized. HTML.

Okay. Yeah. Uh step five here is synchronizing the environment, but uh you all should be familiar with

multiplayer synchronizer now to synchronize any property of anything in the world level. So if you wanted,

you could synchronize the torches, flame sprites, uh the animation of the player,

uh all that stuff. It wasn't Well, I mean on the host it

was. And we've looked at the network profiler. It's like a software that's uh in this picture here you can see I'm

synchronizing all these properties every frame and I'm getting like six kB up 2 kabytes

down. Um that's pretty high at least for this demo.

So uh synchronizing on change for things that don't change often is pretty helpful.

Um that's how you can get it down. Uh, one time I made a game and I had I was

sinking a lot of stuff and my friends joined and we were playing it and then like five minutes in I believe what

happened was I was syncing too many things and it just like killed my network router and they all lost connection to the

server and it all it all messed up. So, uh, something considered

byes 1024. You're right.

Okay, the last step of this workshop

is using remote procedure calls RPCs.

Basically, an RPC is a function that uh you can call on other people's

computers. So, you define this function and then you say, I'm going to let whoever I'm

connected to be able to call this function on my computer. I'm assigned with input parameters and variables and

all that they can assign for me. So we're going to um add functionality to the chat UI script.

Okay. So if we look at that um and I made recent changes to this, so

we're all going to have to make sure we're on the same page. Recent as in last night. Um,

does everyone's chat UI send message function look like this?

I hope. Yeah. Okay, cool. I might have changed that last night. I don't remember.

Okay, so yeah, I made it. So basically how this

works is uh when you type in that text edit on the chat thing

and then you press enter it'll call this send message function and we just get the message that you

typed and then we call receive message on yourself

and you will see a message pop up uh attached to the player like that.

Um what we want to do is instead of calling receive message

here, we want to call it uh on every connected client's computer. So we we

build the message and then we want to send it to them and we can send it to them using RPCs.

And this is a good example of how you can use RPCs to send pretty much any data. you know, if it's like an array of

bytes or like anything, I think RPCs is a good way to send it. So, let's add

that. Uh, in the file system, if you look up server

server chat [RPC.gd](http://RPC.gd), I already have most of this set up here.

So, this is an autoload. So, um,

I vaguely remember that uh RPCs need to be in the same location on each computer

as well or on each scene tree.

Similar to how when you sync uh player nodes, they have to be in the same location on each scene tree.

So, uh if you look at the remote scene, you'll see that this autoload for server

chat RPC is already here. that's already set up for y'all.

So, basically what this does is it's an autoload. It emits a signal saying,

"I've received a message." And there's this function that you can call on it which just emits a signal. What we want

to do is make this function so that other people can call it on your computer and you can call it on their

computer. So we're going to add on the line above it the at sign and we'll type

in RPC and in brackets we're going to type any

pier reliable

and comma call remote or call local sorry

these are all built in these are all builtin settings to the GDO RPC the

uh multiplayer API wrapper.

Um if you control click on the RPC part, you can learn more.

But basically what this means is any pier means that anyone can call this function, not just the host or not just

clients. Uh reliable means that this message will send until the receiver gets the message and say that they got

it. So it's kind of like TCP and call local means that this function

will run on their computer and also on our computer as well.

So now that we've defined this RPC function,

does this part make sense? Yeah. Okay. So we we we made a function,

we say how it can work and we can call it on other people's computers. If we go

back to our chat UI and we replace the receive message line

with server chat RPC dot uh receive message.

So if we put that there and instead of calling the function like this

what that would do is only call it on our computer. we want to call it on everyone's computer when we send a chat

message right we want to send it to everyone so instead what we do is we say

receive message RPC and that will call this function on

every connected client so everyone else who's in the server additionally we want to pass in our

message as the argument

if you wanted to send this to a specific client You could do RPC id and say if you want

to send it to only the host you would say one comma and then the arguments of

that function which is our chat message or if you want to send it to another client you say like 4 million whatever

but we're going to send it to everyone.

Okay, let's see if that worked.

Yeah. Uh, I just typed hello on the client and on the host. You'll see that hello came in and that hopefully matches

on your computers as well. Cool.

Is there a way to differentiate who made the call? Because it sounds like it just

kind of come to the same place. Yes, there is a way to differentiate who made the call. So, if we go to survey

chat RPC, um, since this is an RPC function, I believe

there's a function called sender.

That sounds right to me. What was it? Multiplayer.

Get remote sender ID. That's it. Thank you. Uh, yeah. So, if you call this

inside that RPC function, it'll give you the ID of whoever called that function.

And then you can do stuff like maybe we uh maybe we add that

to the chat message. See if that works.

Sweet. So now you can see that client 2 million whatever says hello.

So yeah uh you can do a lot with RPCs. Um on one of my projects I wrote

a procedural generation thing and then I just took the entire

two-dimensional array and stuck it in an RPC function and sent it to the clients.

Although after I did that, I realized I probably just should have sent the seed to them instead, but

it worked. So, you can do a lot with this. Um, I mean,

if you can send a string to anyone, you can pretty much send anything, which also is something to consider for cyber

security, but I'm not going to give any advice on that.

Um, did you sync audio with that or is that

just a bad idea? I don't know about that, but I know

there are uh add-ons I think or plugins or whatever for GDAU that have like

voice over the network type thing. Um, which I definitely want to check out

because I want to do that multiplayer rhythm game. That sounds crazy.

Sounds tough. It's already hard to sync audio with like play cursors and write cursors and stuff, right? So

that sounds crazy, but I would love to see it. Okay, so you

So that's RPC functions. Um, and now we are at our recap phase. So,

right now, everyone in this room should be confident in how to connect two or more computers over an internet

connection with one person hosting a server. Uh, you should all be able to spawn and synchronize characters for

each player. You should be able to synchronize world elements across each client and you should be able to use RPC

functions to send any sort of data across the network. So, that's pretty awesome, right?

Uh, and then here are other resources I have. Uh, the GDO level documentation.

Um, here's my advanced FPS project that I was talking about. Uh, Devlog Logan's tutorial. I made some

YouTube videos about multiplayer. And I have a dedicated

headless server and client repo. I don't recommend doing it, but if you want to

check it out, you can check it out here. It's two separate GDATO projects. One of them is the server, one of them's a

client. And then when you synchronize, you can synchronize exported variables.

So like all the players position I exported on the on the server

and then you can synchronize like that. But I don't think that's the best way to do it. I don't

worst client. Um unless you want to. Yeah. So

the um the server repository doesn't have any graphics. It doesn't

have any levels or anything. All it knows is the player, the positions or

the positions of the players and um the game mode and stuff like that. But it's

like super bare bones. So, when I was like, "Oh, I want to add NPCs." And that's fine, but then if you don't know

where the map is, if you don't have any data about like the map and the world geometry, how are you going to

populate it? How are you going to have NPCs run around and do stuff? You know, it's really tough. And it was a 3D game. If

it was 2D, you could probably figure something out. Like 3D is a lot more.

Something you can do is when you go to export

so you have your headless one graphics effects and stuff like that you

don't include and then the headless one can be slimmer and still in the same project.

That's a really good idea. So when you export to make a headless server, you can have the headless server ignore all

your graphics in the file structure. And that way when you export and you want to

put it on like a server or something, it's a smaller file size. That's really good. That's a good idea. That would

have been a lot smarter than uh two projects. At the beginning, you differentiated between split screen, Mario Kart, and

network play. If you wanted to make a game that supported both, like should

you treat the local multiplayer or should you treat the local players as multiplayer clients like

you want to be happy? Yeah, that's a great question.

I don't know because I mean you could just say like everyone who's on my computer is the host. Mhm.

But then if you're trying to do any logic like like who's the authority, one client or one pure ID for each

player, then you would run into problems. Yeah, I don't know. That'd be a cool uh cool thing to check out for sure.

Yeah, that that's all the content I had for multiplayer basics. If you guys have any questions or want to workshop more

stuff, I think we have time.

Have I ever put the headless server in a docker container? Uh, no. But I think

it's probably easy.

Yeah, I haven't done it. Has anyone done that? Have the server in a Docker container? No. Yeah, I'm still learning Docker. So,

sounds good. Cool.

Anyone want to see any cool stuff? Yeah. What's up? What's the portion of the code that like

So, I'm guessing this is all peertopeer kind of stuff. This is peerto-peer. And then what about when you like want

to make like a multiplayer game and then like you outsource the server to like some server farm?

Yeah. So, the way I would do it, which I haven't done yet, but I think the way I would do it is like when you make like a

headless server. Um, instead of having one player be the

host, you just don't have a player for the host. You would just make the

server, you say like host or well, if it's headless, you won't say anything. You just say like I'm hosting. And then

you won't make a player for them. And I think it should work. Yeah. Then it's even simpler because in

this case we had to add weird logic where the host also gets a player that was like a separate function.

Yeah. So you just want to emit the uh spawn player for s or for host signal.

I work in MMOs and I wouldn't necessarily run a headless server at all just

you need to bucket them by something like you can't have let's say

they don't have to be like this

what the engine

would

Oh, I'm saying like if you want to have like

Oh, yeah. You have you already have I mean,

how do I get back?

Yeah, the advantage is the the headless server is running your game exactly the

same code. It's running exactly the same code.

You don't have to run it. You don't have to write it twice. Once for the server

in some server language.

the headless server export

what's up. Oh, that's a great uh

Yeah. Okay. That's an interesting thing. Yeah. I was running two multiplayer games. Uh both of them using the same

port and probably using the same scene tree setup. So

probably syncing different data but the same data.

That's kind of fun if you're into that.

So, actually, quick question with that. Yeah. Is there a way to catch that the port's occupied Gadell

and basically throw an error? Yeah, there's there's probably some way in the

there's probably some way in the docs or in the multiplayer API. Uh you can do

a lot with Lego like checking like uh operating system stuff. So, probably

somewhere Yeah.

Yeah. Community has the same stuff for free. Tell you. So, when I first um was preparing for

this workshop, I like made this demo, but I was like, it's pretty complicated. And I was like, would this be the best

way to teach multiplayer? And I was like, one of the concepts I was like, what if what if we set up a server

and you all make your own clients and you all get to make your own weapons and stuff like I was like, then you just have people

flying around and like insta killing everyone. All right. I don't think we would enjoy.

Yeah. Yeah. Someone do it better. Um, yeah. This is a

trying to figure out how to like FPS to work with

not designed for my laptop technology. Yeah.

Um, wait. So, this would actually

Yeah. So, since I'm the host, I would first have to forward on the router, but

I don't think Microsoft would like that. So,

Oh, yeah. Yeah, I was thinking should we try

if you have it downloaded. I think probably could

but it was only still on. I try I mean the you all have the git repo. I think what happens if I want to test it data?

We'll just see if it works. Structured very similar structured very similar. Yeah. Um

to the data structure. Yeah. FPS Nash 3 AC. So up here I have uh a tracker to track

your ping. So if you guys are interested in like seeing how your ping is um that's pretty helpful. This is the

host though. So is pretty good. Um yeah and then it's over there.

Normal. All right. Don't hack me.

We used to do like This thing is struggling.

Look at this. I'm probably I think that's it right there. So,

but my plan is to using the entire network like an interface. So

that way if I want it bigger, not websockets or like some other

service that does something. Yeah, I could just do that without disruption.

Uh 2526. Yeah, like I

the uh the IP. Um there should be a connect menu. I don't know what

Oh, yeah. Oh my god, someone's in here.

So, I built a Cards Against Humanity clone. What's going on here? on the web. Oh yeah.

So instead of the the port number, you put the IP address a similar um

IP goes in the the other one if you replace local host

either. That's crazy. I did not think that would work.

Yeah. So uh

uh I think it's just this laptop. Like this thing is struggling. I got 28 FPS.

Uh 172 ping. Whoa, that reload is amazing. If you hold tab, uh I tried making a

scoreboard with um I think it's like the item item UI

node, but it doesn't like it doesn't like it

doesn't resize, right? That's crazy. Multiplayer.

Let's go. I have a big head.

Yeah. Yeah. So, these are hit scan. So, it's

just a raycast. You say I hit uh 197.

Um they're hit boxes actually, which is kind of cool. But uh

What's the address? Uh the address

1060 3294

that changes right

I don't know too. Oh my god. How is this working dude? This is all on my laptop.

I love it. Yeah, I'm hosting. Yeah,

dude. There's so many. Oh, yeah.

The first one. Oh, wait. This one might be the host, actually. Yeah, get this guy out of here.

I think I have disconnect handling properly.

just I'll just full screen it. I'll just full screen. Um,

what's up? A rocket jump. Oh, uh, no rockets yet. I

was going to add another weapon. I don't think I did that, though. Oh, if you press two, I think

you put away your gun.

Wow. Oh, that's so sick. And there's a kill

feed, too, if you guys want to check that out. It's really small, though. The kill feed.

Oh, it's so tiny on my screen. Yeah. Uh 10 60 32 94.

And where do we input that? Uh the event code.

You got uh MS event.

I can restart it. I'll restart it. I'll restart it. Who's that?

Oh, I can't leave. Um

yeah, you get a plushy. Oh. Yeah, we have uh pretty great art.

Great question. Oh, we can do that with all join. See how many people we can

get.

Um

Oh yeah. It does. It doesn't. Pretty smooth.

Yeah. No, that was no lag on my computer. Oh, yeah. That's good. Yeah. It's the PS graphics.

The PS1 graphics. Yeah. Yeah.

Dude, this is the most people I've ever had on one game I've made. This is crazy. server, I guess.

How many do you get for the one? I don't think anyone's played in

multiplayer, actually. I think that was just us. Yeah, cuz like when you play game jam games, it's like

you're playing for a few minutes. Yeah. Yeah. And then also in order to do that, you have to port forward. So, it's

like Yeah. Well, I was thinking of hosting it on like a third party like Lenode or

whatever. I was saying again one of those then I was like is that what there was it was I guess

months ago at this point someone made like an MMO for the game fast oh really

for good wild jam I think was it multiplayer

I should have checked that out I'm so bad at playing the games I like I do the good wild jam for like nine days

straight burn myself out and I was like oh you want me to play games for five days and rate them and like give them time and

effort. Oh god. Uh should be the game tree is the

default scene. Oh yeah, if you want. I guess you could

give yourself more. Um I'll take a look.

Here. This is so sick.

Oh yeah. Thank you, John. Yeah.

Oh. Uh yeah, if you go back um or try it again. I think you're missing the dots.

Oh, I can see my point. Yeah. So, um sorry, it's a 10 dot. Um whatever that is. Dot.

One more dot. Yeah, there you go. What is my name? How much help?

Find out how much help you just look. So, does everyone feel confident about making multiplayer games now?

Yeah. Okay. Okay. Okay. I I want people to make them cuz like I think it's just the best thing.

Fancy. Where'd everybody go? Are they running around? Yeah.

It makes much more. [Laughter] Who's flying?

Oh, did I leave that in? Oh, yeah. Here we go.

Oh, I was thinking there was no validation. So, somebody just set the jump point really high.

That's amazing. If you press two, uh, you put your gun away and then your arms go into airplane

mode.

Wow,

this is beautiful. This belongs in a museum.

Very good. Oh my god. Where did I

Oh, someone has a problem.

Is is there a problem over here? We having a problem over here.

Yes. Yeah.

I think um so it looks like you did most systems I think.

What we're missing is uh since we're going to spawn the players during runtime.

We're going to want to get rid of that guy. I don't know how you delete.

Oh yeah. So there's already a So that's like the single player player.

You're saying? Yeah. So you delete that single player for a while

and then uh once people connect um C++.

Yeah, they will spawn in there. So if you try now

Yeah. So that's that's good. Um yeah. Yeah. So once you hit host, if

everything's connected for here, hit hit join on the client. Okay.

So, um I didn't realize that.

So um onet server it references like uh if you click on

you know is that connected in my

green can you control click on that

I don't think we've gone out okay can you um every single time.

Delete this and name it like with a capital E server.

And then get rid of the underscore too as well. Um that might be messing it up.

Yeah. So, and then um because when you define this last name, it defines like kind of like the name of the node.

Oh, maybe later this week. Huh? If if you go back to server

and then if you just double if you copy that and then go back to game. No,

because uh and then it right there.

So random photos like

it has. Yeah. So, um let's go to the player script or the player

that is and then player controller. If we look in there,

if not is multiplayer authority for you. Okay, that's good. Oh, and then

maybe just comment that one. I think by default um

oh 5 minutes

Yeah, I I was hoping everyone would get it. Um, I guess Do you think anyone else did?

Yeah. Last night. Yeah. Thanks. Thanks for all the help, too. Awesome.

Lift it up and it follows I've never used the microphone before.

I saw it. Yeah, if you um look up I think it's like GDO

VIP. VIP. Yeah, it's like voice over IP but with the control.

I think it's a plugin. Yeah, they might have open source solution.

Um a couple games on there. Okay, so let's see. So

yeah, like if I crash, I'm not going to smash that.

And it to a certain extent it works because

yeah well

let's check out your players manager multiplayer client that's your multiplayer client

uh is missing a player actually. So you want to have a player as child of the multiplayer client.

So if you um control or command shift A on there

and add player shifts up.

Yeah. So you can instantiate a scene that you have from your file system. Yeah.

I think that should be it. Jesus Christ. Yeah, we try that.

Yeah, they're probably like this big. It's like a decent size drone. Yeah, that's what that's

there's no there's no guards on it. Yeah. All right. So, so you followed you followed like all the steps, but I think

you just missed one if you just went on. Okay. So, you have you have the synchronizing, dude.

I like sent this to people. I was just like,

can we start again? Yeah. I just want to see what actually we didn't like turn off. So, it just

kept Jesus Christ. If anyone was near it

or something

a picture of the people

on the remote entry, this is super helpful because it shows me what's

this part like this is like this is like when you're during the game and all that but like once you hit run everything in here

is actually filled in. So, looks like you got two players.

We'll see. Yeah, that probably is. Oh, thanks.

So, this guy only has one. Well, I thought I I thought it was like he was fine before and he just ground

and during

question

is like a really bad match up for Martha.

It's just like

their staff like avoids a lot of your attacks.

Oh, it is player.ts. TSM. Um, let's switch this to be multiplayer. So, if we get rid of that and

[Music] that might

basically everything that's in this auto spawn list defines the things that can be synchronized.

Oh, you still like that? So um

multiple times. So since this is in that list when you

spawn it you don't want anything to escape. Oh sweet.

So if they went straight up they would have figured it out.

No longer ask we can find that out. Yeah. You go to player

first off. Yeah. Dude, figuring all this out the first

time was so hard for me. That's why I'm like, I want to do a workshop. Um, okay. So, player

like Southw.

Here we go. Uh, breaking down. What are we looking for? Um, oh,

so instead camera. So, let's get a reference to our camera

here. What is it? Click and play. Got it.

It was so hard to fly it around. I know it's or whatever.

It's just super light and once you certain takes it Oh, yeah. There was electronic layer.

Yeah. Oh, really?

I don't even know how I broke. Oh, because I was checking see if they actually should. My dad my dad

baseball. Oh yeah. Yeah. The default one, right?

No. Uh we deleted. Yeah.

That's good. It's good. Bad dad joke. Yeah. Yeah. So it was funny because when

we were um you're supposed to delete it before like Yeah. Yeah. Just straight from the scene

tree. Yeah. Yeah. Yeah. Yeah. So you start with zero players and then once you hit host it's

like I need a player. Yeah. Let me

Oh yeah. Yeah. You guys done it pretty easy but

Yeah. I think the connected

Oh, yeah. The web I did. Give us

try doing something. Yeah. Yeah. Yeah. Exactly.

**Jordan. All right, everyone. Uh that is the end of the workshop. Thank you for coming. Thanks for coming to uh go Boston. And**

**uh I hope you all learn something.**