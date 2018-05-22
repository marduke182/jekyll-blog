---
layout: post
title: Improve productivity using docker
head_title: Improve productivity using docker [Docker]
summary: I would like to share how I increase my productivity using docker to do common tasks.
last_modified_at: 2018-05-20T17:04:00+01:00
preview_image: docker.jpg
next_amp:
  url: limit-rails-memory-usage-fix-R14-and-save-money-on-heroku
  title: Reduce Rails Memory Usage, Fix R14 and Save Money on Heroku
---


{% asset docker.jpg class="center-image post-main-image" alt="Docker logo" !width !height %}

I didn't knew Docker one year ago, but I start using it in my company and few days later I used a lot for my personal projects this are my reasons.

> I don't need to install everything in my machine

I try a lot of technologies every day, this force me to install programs, database, etc. Only to stop using few days later and my pc, Docker allow me to test everything without installing everything. For example:

If i want to try rails, i used to install ruby, database, and start coding, but now i open my console and get up a docker machine with all what i need

{% highlight bash %}
// Dockerfile
docker run -it -v /path-src:/src bash
{% endhighlight %}
 
> I can test my application in complete isolation

When you test your application, usually run perfect in your local environment, but when you deploy something to production or try to run in another computer, you notice that something is wrong in your configuration, etc. 

Docker helps me a lot with this. I have my tests running in a docker machine, this assured me consistency over systems, I use **docker compose** for this.

{% highlight javascript %}
// docker-compose.yml
version: '3'
services:
  mongo:
    image: mongo:2.6
    ports:
      - "27017:27017"
  backend:
    build: ./backend
    depends_on:
      - mongo
    ports:
      - "3000:3000"
  frontend:
    build: ./frontend
    depends_on:
      - backend
    ports:
      - "3001:3001" 
{% endhighlight %}

> Anyone can run my project

As programmer we must give enough information to allow collaborators contribute in our project. But sometimes a good documentation is not enough, because we are not handling a lot of variables, architectures, environments, etc.
 
 When we use Docker all projects run in the same way, *docker build* and *docker run*. Also we can publish our docker image in server likes *docker hub* to allow people run the project without having the code installed.

> For larges company is common used to handle complicated deploys

As you see, we can run and show how the application is connected between, with this information tools like **kubernetes** or **swarm** can do amazing go to handle deploys, scalability, etc.

Swarm for example receive a docker compose and with few configurations you can set a cluster of servers that will handle your scalability, load balancing, service discover, deploys, etc. This is amazing is not weird DevOps guys love docker so much. 

Kubernetes does something similar but with his own configuration.

## In conclusion

