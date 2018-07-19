---
layout: post
title: My final react folder structure
head_title: My final react folder structure [Opinionated]
preview_image: react-folder-structure.jpg
keywords: react, components, containers, folders
summary: 
---

Create React App solved the issue of project startup and Javascript fatigue, but there is not a common pattern for folder structure, I've been used different ways from projects to projects (sometimes in the same project, yes, It was a chaos). However, we had a meeting last week to decided the company rules. Thanks, I was on the right path.

## Folder by feature, not by type.

When you start with redux for example, a common way to structure your folder is having folders for *actions*, *constants*, *reducers and* *selectors*, the truth is, this is the worst approach you can do, every time you want to implement a new feature, you need to open 4 different folders. 

[comment]: &lt;> "Add a image here representing the last case"

The same happens with react, your separation could be by *components* or *containers*, or having *atomic design (organism, molecule and, atoms)*, both solutions ends with big folders hard to find something.

[asd]: &lt;> "Add an image to container/components and atomic design"

All this patterns are good but are not scalable, my current approach is what I called **Feature Module**, the idea is to encapsulate everything related to logical implementation together. Is the same as *microservices* on the backend, we develop our app to be able to live separated from the big picture.

[ comment ]: &lt;> "Add image representing feature module"

## Feature Module



A feature module looks like this:

```bash
auth
|_components
|_containers
|_libs
|_auth.redux.js

```

You must have noticed that I am using the *components*/*containers* pattern here, for me a *container* is a **component connected to redux store, execute I/O operations to pass the properties needed for other components**. Why do I create another folder? I want to identifiy what components contains the business logic to react fast to changes. In some way having this folder make you think twice to connect a component to the store.

> Tip: Having unidentified components connected to store increase project complexity, performance and reduce reusability. 