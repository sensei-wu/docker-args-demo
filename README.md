# A step by step comparison of ENTRYPOINT and CMD commands of docker

## Theory

Both ENTRYPOINT and CMD are commands which are used for customizing the startup behavior of a container.

Both commands can be used interchangeably to serve similar purposes, but nevertheless 
there are subtle differences between them.

ENTRYPOINT is the right way to specify a startup command for a container.

CMD is meant to be used for passing arguments to the startup command specified by ENTRYPOINT.

On top of that, both commands could be executed either in _shell_ mode or _exec_ mode.

In shell mode, the command is executed from within a shell whereas in exec mode, it is executed directly.

In the following sections, I'd like to demonstrate how these differences play out in practice by using the classic 
[fortune](https://linux.die.net/man/6/fortune) program which prints out a random quote each time it is invoked.

We install fortune inside an alpine linux base image and then invoke the program using `CMD` or `ENTRYPOINT`.
We will inspect the difference between shell and exec mode and also check out how we can pass arguments to the 
container while running the container.

#### v1: without a CMD or ENTRYPOINT

If you fail to specify at-least one of CMD or ENTRYPOINT, your containers won't execute anything.
```
FROM alpine
RUN apk --update add fortune
```

`$ docker image build -t docker-args-demo:v1 .`

```
$ docker run --rm docker-args-demo:v1
$
```

#### v2: Using CMD in shell form

```
FROM alpine
RUN apk --update add fortune
CMD "fortune"
```

`docker image build -t docker-args-demo:v2 .`

```
$ docker run --rm docker-args-demo:v2
Real Users find the one combination of bizarre input values that shuts
down the system for days.
```

```
$ docker run --rm docker-args-demo:v2 hostname 
fd43740dcdde
````

#### v3: Using CMD in exec form

```
FROM alpine
RUN apk --update add fortune
CMD ["fortune"]
```

`$ docker image build -t docker-args-demo:v3 .`

```
$ docker run --rm docker-args-demo:v3 
Not Hercules could have knock'd out his brains, for he had none.
		-- Shakespeare
```

```
$ docker run --rm docker-args-demo:v3 hostname
7155c32c6b9b
```

#### v4: Using ENTRYPOINT in shell form

```
FROM alpine
RUN apk --update add fortune
ENTRYPOINT "fortune"
```

`$ docker image build -t docker-args-demo:v4 .`

```
$ docker run --rm docker-args-demo:v4 
America may be unique in being a country which has leapt from barbarism
to decadence without touching civilization.
		-- John O'Hara
```

```
$ docker run --rm docker-args-demo:v4 hostname
Dear Lord:
	I just want *one* one-armed manager so I never have to hear "On
the other hand", again.
```

#### v5: Using ENTRYPOINT in shell form with non terminating container

```
FROM alpine
RUN apk --update add fortune
ADD fortuneloop.sh /bin/fortuneloop.sh
RUN chmod +x /bin/fortuneloop.sh
ENTRYPOINT /bin/fortuneloop.sh
```

`$ docker image build -t docker-args-demo:v5 .`

```
$ docker run --rm docker-args-demo:v5
Configured to generate new fortune every 3 seconds
Twenty Percent of Zero is Better than Nothing.
		-- Walt Kelly
We gave you an atomic bomb, what do you want, mermaids?
		-- I. I. Rabi to the Atomic Energy Commission
Micro Credo:
	Never trust a computer bigger than you can lift.
This process can check if this value is zero, and if it is, it does
something child-like.
		-- Forbes Burkowski, Computer Science 454
In America today ... we have Woody Allen, whose humor has become so
sophisticated that nobody gets it any more except Mia Farrow.  All
those who think Mia Farrow should go back to making movies where the
devil gets her pregnant and Woody Allen should go back to dressing up
as a human sperm, please raise your hands.  Thank you.
		-- Dave Barry, "Why Humor is Funny"
This planet has -- or rather had -- a problem, which was this: most of
the people living on it were unhappy for pretty much of the time.  Many
solutions were suggested for this problem, but most of these were
largely concerned with the movements of small green pieces of paper,
which is odd because on the whole it wasn't the small green pieces of
paper that were unhappy.
		-- Douglas Adams
```

```
$ docker ps
CONTAINER ID        IMAGE                 COMMAND                  CREATED             STATUS              PORTS               NAMES
7cd79a66dc6e        docker-args-demo:v5   "/bin/sh -c /bin/for…"   4 seconds ago       Up 3 seconds                            jolly_hodgkin
```

```
$ docker exec -it 7cd79a66dc6eef ps x
PID   USER     TIME  COMMAND
    1 root      0:00 {fortuneloop.sh} /bin/sh /bin/fortuneloop.sh
   27 root      0:00 sleep 3
   28 root      0:00 ps x
```

```
$ docker stop jolly_hodgkin
jolly_hodgkin
```

#### v6: Using ENTRYPOINT in exec form with non terminating container

```
FROM alpine
RUN apk --update add fortune
ADD fortuneloop.sh /bin/fortuneloop.sh
RUN chmod +x /bin/fortuneloop.sh
ENTRYPOINT ["/bin/fortuneloop.sh"]
```

`$ docker image build -t docker-args-demo:v6 .`

```
$ docker run --rm docker-args-demo:v6
Configured to generate new fortune every 3 seconds
If money can't buy happiness, I guess you'll just have to rent it.
Brace yourselves.  We're about to try something that borders on the
unique: an actually rather serious technical book which is not only
(gasp) vehemently anti-Solemn, but also (shudder) takes sides.  I tend
to think of it as `Constructive Snottiness.'
		-- Mike Padlipsky, Foreword to "Elements of Networking Style"
Think of it!  With VLSI we can pack 100 ENIACs in 1 sq. cm.!
Whenever I hear anyone arguing for slavery, I feel a strong impulse to
see it tried on him personally.
		-- A. Lincoln
```

```$ docker ps
   CONTAINER ID        IMAGE                 COMMAND                 CREATED             STATUS              PORTS               NAMES
   07f5e3718215        docker-args-demo:v6   "/bin/fortuneloop.sh"   28 seconds ago      Up 27 seconds                           funny_cartwright
```

```
$ docker exec -it clever_williamson ps x
PID   USER     TIME  COMMAND
    1 root      0:00 {fortuneloop.sh} /bin/sh /bin/fortuneloop.sh
   22 root      0:00 sleep 3
   23 root      0:00 ps x
```

```
$ docker stop clever_williamson
clever_williamson
```

#### v7: Using ENTRYPOINT in exec form and CMD as argument

```
FROM alpine
RUN apk --update add fortune
ADD fortuneloop.sh /bin/fortuneloop.sh
RUN chmod +x /bin/fortuneloop.sh
ENTRYPOINT ["/bin/fortuneloop.sh"]
CMD ["3", ""]
```

`$ docker image build -t docker-args-demo:v7 .`

```
$ $ docker run --rm docker-args-demo:v7 5 "-e startrek"
  Configured to generate new fortune every 5 seconds with params -e startrek
  Peace was the way.
  		-- Kirk, "The City on the Edge of Forever", stardate unknown
  To live is always desirable.
  		-- Eleen the Capellan, "Friday's Child", stardate 3498.9
  You humans have that emotional need to express gratitude.  "You're
  welcome," I believe, is the correct response.
  		-- Spock, "Bread and Circuses", stardate 4041.2
  No one may kill a man.  Not for any purpose.  It cannot be condoned.
  		-- Kirk, "Spock's Brain", stardate 5431.6
  "Life and death are seldom logical."
  "But attaining a desired goal always is."
  		-- McCoy and Spock, "The Galileo Seven", stardate 2821.7
  You say you are lying.  But if everything you say is a lie, then you
  are telling the truth.  You cannot tell the truth because everything
  you say is a lie.  You lie, you tell the truth ... but you cannot, for
  you lie.
  		-- Norman the android, "I, Mudd", stardate 4513.3
```