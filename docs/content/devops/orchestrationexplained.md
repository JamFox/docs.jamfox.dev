---
title: "Orchestration Fundamentals Explained Simply"
---

At some point, when I first started my path down the journey of DevOps and managing IT infrastructure at enterprise level, my team was tasked with deploying a containerized web app for storing documents. Catch being that no-one on the team knew anything about running containerized applications. But no problem!

> Working in IT is all about being able to new problems, so we'll learn on the job!

Nothing wrong with this approach if given sufficient time, but when you're told to deploy in a month? That's when you dive right in and find yourself in the middle of all kinds of magical words like: microservices, service meshes, service-level fault isolation, interoperability, container orchestration, horizontal scalability, service observability and discovery etc. So in the end you're sitting there with fire and explosions going off all around saying "we're learning on the job, this is fine!"

My goal here is to provide not a very technical, easy to understand overview of what it means to go from a standard monolithic all-batteries-included app running on bare metal host to an orchestrated containerized app following the microservice architecture. This is the overview I wish I got before I jumped into the fire described earlier.

## Meet The Monolith

Let's set the stage: say that me and you work for some company. The company's motivation is to make more money, that means reducing operating costs which in itself means making the tasks of the employees easier and more efficient. That is to say that **our goal is to make our jobs as easy and efficient as possible**. At first, this company was still using faxes and all the accounting was done on paper. But we built this wonderful web app for storing the companies documents (called Document Webapp) so the company can stop renting a whole warehouse for storing and handling physical stacks of paper. For the Document Webapp there was no other product that fit our company so we coded it ourselves in your favorite programming language. We ended up with a single executable that we test on the Test Server and run on the Production Server. Both servers are identical and run the same OS (let's call it the OldOS 1), same everything to ensure that there are no surprises, because when the intern tried to run it on his laptop with a different OS he got a lot of weird errors.

By building this Document Webapp we reduced the costs by making the tasks of the employees easier and more efficient. But now instead of all the people at the document warehouse, we are managing the Document Webapp. We don't have to do as much work as all the people handling the paper did combined, but it's a lot of work to manage the Document Webapp so we would like to make OUR jobs easier and more efficient, so let's see what we could do.

Let's look at the Document Webapp in detail. Because it's a web app it is using our companies load balancers (also acting as reverse proxies) so users can access it from the internet, fortunately load balancers are separate from our app and are taken care for us. But we coded our own:

- Web front-end
- Document Database (to store our documents)
- Document Search (so clients can search for documents without scrolling through a list of them)
- Document Caching (so the documents are delivered efficiently to clients)
- Authentication System (to provide logins and private documents for clients)
- Web back-end (to tie all the previous systems together)

And **the components of the app run inside that one executable**!

When we want to run a new version the the Document Webapp here's our deployment process at this point:

1. SSH into the Test server
2. Stop the Document Webapp
3. Clone and build the latest Document Webapp
4. Update the system packages if needed
5. Start the new Document Webapp
6. Repeat the same in the Production Server

Quite simple! But we can automate that, so we run the same steps with Ansible. Even better! Now our process looks like this:

1. Update Ansible repository with the version of the Document Webapp and version of the system dependencies we want to deploy
2. Ansible runs the following automatically on the Test server:
    1. Stop the Document Webapp
    2. Clone and build the latest Document Webapp
    3. Update the system packages if needed
    4. Start the new Document Webapp
3. Repeat the same for Production Server

By doing all this, manually or with Ansible, **the application is tied to the host that we run it on *and* the hosts OS**. That is to say, if the OS or the hardware of the host has issues then our app will also be affected. Transferring the app to a new host means adding a new host in Ansible with the same OS and letting Ansible configure it with our dependencies and the Document Webapp.

## Meet The Container

Then one day, it turns out we need to upgrade all our servers' OS from OldOS 1 to OldOS 2 because the previous version is now no longer supported and does no longer get security patches. Remember when our intern tried to run the Document Webapp on his laptop with a different OS got a lot of weird errors? Well now we are facing the same problem, because the application is tied to the OS. But can we somehow isolate Document Webapp so that it is able to run on any machine? The answer is application containers!

Containerization is having the operating system take features and properties normally considered global, and reduce them to private versions or limited access/resources as a means of restricting or isolating access to those resources. Note that it's not the same as running another virtual machine (VM). **VMs isolate on the kernel level, containers isolate on the OS level**. Furthermore, there is a difference between system containers and application containers. System containers take the place of VMs when there is no need to isolate on the kernel level, because they have less overhead because of not having to simulate the kernel. System containers are usually used as you would use a VM. However **application containers are designed to only run a single process** and only contain bare minimum of the OS dependencies that the said singular process needs. Application containers are designed to be treated as you would treat the executable without containerization. You're not supposed to remote into the container, run commands and install stuff in the container, they're not supposed to have their own IP address etc. If you need to modify the container, you stop the old one and launch a new one with the modified contents. To put it simply **application containers are emphemeral** and **system containers (like VMs) are long-lasting**.

But we are storing documents on our app, how can it be ephemeral? **We certainly do not want the data to be ephemeral**, otherwise on each restart of the container we would lose our data! This is key point to understand: **application containers need to be provided with a separate persistent storage that is not part of the container itself**. Simplest solution is to mount a directory from the host into the container. So on each restart the container uses the same data directory and our data is long-lasting while our container is ephemeral!

Going forward if I mention containers, I mean application containers not system containers.

So we create our container image for our Document Webapp. After creating the container image and launching a container with that image we will have it running on the servers with OldOS 2 inside a container that runs the Document Webapp executable with only the bare minimum dependencies from OldOS 1. In fact if the intern tries to run the Document Webapp now, then using the container they will not have any problems with their OS! **With the container we have isolated the app from the OS of the host we are running it on**.

Now our process looks like this:

1. Update Ansible repository with the version of the Document Webapp container image we want to deploy
2. Ansible runs the following automatically on the Test server:
    1. Stop the old Document Webapp container
    2. Start the new Document Webapp container
3. Repeat the same for Production Server

At this point **the containerized app is still dependent on the host we are running it on** though! If there are issues on the hosts OS then our app will not be affected (unless it's serious), but if the hardware of the host has issues then our app will still be affected.

## Meet The Orchestrator

Then at some point the Test server dies and it becomes the center of attention because what if this were to happen to Production? Management and we want to make sure that this absolutely does not happen to the Production Server. We could run a couple more Production servers for high availability and have a load balancer in front of them. This is certainly a good solution, but adds management overhead since now we have to manage multiple servers. Since we are already using containers, let's use an orchestrator!

With an orchestrator we can set up a number of hosts in a cluster and then specify how many instances should be running and how these instances should be running and the orchestrator will take care of everything. However this comes with some new challenges as now where the Document Webapp is running becomes dynamic. The orchestrator will decide on it's own where it wants to run it and where it is the most efficient.

Where the services are running, which port they are running on will all be dynamic with an orchestrator. The dynamic nature of orchestrating means we have to adapt our thinking and infrastructure to handle everything being dynamic. This means figuring out how to:

- load balance and direct traffic to the services (often called ingress): how do we direct traffic to instance(s) of our service if we don't know the host it is running on?
- handle logging and aggregating logs for easier debugging: how do we know which instance had a problem, how do we know it was the orchestrator, where are all the logs located?
- manage TLS certificates: it is not possible or good practice to spam certificate requests for all nodes, how do we distribute them?
- cluster internal communication: if services are running on arbitrary ports, how can they communicate with each other?
- handle stateful storage: if the service can run on any host, how do we ensure it will always have the same data?

These are non-trivial obstacles, but once solved the Document Webapp **service(s) can be separated from the host(s) it is running on with an orchestrator**. It will no longer matter where it is, the orchestrator will make sure the defined number of instances will be up if enough nodes in the cluster are alive. If one dies with a service running on it, the orchestrator will deploy a new instance on another host et voila, it's as easy as that!

Now our process looks like this:

1. Define to the orchestrator how Document Webapp should be run and how many instances should be deployed
2. Orchestrator will compare current state to defined state and do the following:
    1. Check version and do a rolling update if current is outdated
    2. Check how many instances are running, stops or starts new instances to match defined state
    3. Takes care of load balancing, storage, certs
    4. Reports health of defined services

The orchestrator will get us as close to true Infrastructure as Code as today's technology allows. At this point **the containerized app is no longer dependent on any particular host(s) or any OS.**

## Bonus: Meet The Microservices

With orchestration as the last step we have surpassed the most critical and hardest parts of deploying the Document Webapp. However if we wish to give it a final cherry on top we should move to the modern microservices architecture.

Before we looked how our app consisted of multiple components that are all part of one executable:

- Web front-end
- Document Database (to store our documents)
- Document Search (so clients can search for documents without scrolling through a list of them)
- Document Caching (so the documents are delivered efficiently to clients)
- Authentication System (to provide logins and private documents for clients)
- Web back-end (to tie all the previous systems together)

If we update one of these components, we need to redeploy the whole app. To minimize downtime we should break these components apart into separate services. That way we can update and manage each of them separately. This has the added benefit of always being able to easily switch out the components provided that our application's interfaces were coded to support this instead of being stuck with the built-in solution for eternity.

Breaking up applications comes with the drawback of having more complicated architecture. Designing components to be pluggable and dynamic will inherently be more complex and also complicates debugging, but it will provide the value of being very flexible as technologies change and evolve.

## Recap

To put it very short:

- **Containers** separate service(s) from the host OS
- **Orchestrators** separate service(s) from hosts themselves
- **Microservice architecture** allows service's components to be more flexible in terms of managing and deployment
