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

```bash
src
|_components
|_containers
|_auth
  |_actions.js
  |_consts.js
  |_selectors.js
  |_reducer.js
```

The same happens with react, your separation could be by *components* or *containers*, or having *atomic design (organism, molecule and, atoms)*, both solutions are good, but as your application goes bigger this component will too, so becomes hard to navigate.

```bash
src
|_components
  |_Fields
    |_Input.jsx
    |_...
  |_LoginForm.jsx
  |_CreateAccountForm.jsx
  |_DashBoardMenu.jsx
  |_...
|_containers
  |_LoginPage.jsx
  |_CreateAccountPage.jsx
  |_DashBoardPAge.jsx
  |_...
```

All this patterns are good but are not scalable, my current approach is what I called **Feature Module**, the idea is to encapsulate everything related to logical implementation together. Is the same as *microservices* on the backend, we develop our app to be able to live separated from the big picture.

## Feature Module

A feature module looks like this:

```bash
src
|_auth
  |_components
  |_containers
  |_libs
  |_auth.redux.js
```

You must have noticed that I am using the *components*/*containers* pattern here, my definition of *container* is kind of different, it's a **component that could be connected to redux store, execute I/O operations or contain business logic**. 

**Why do I create another folder?**, I want to identifiy what components contains the business logic, because this components are the ones that hard to test and the entry point of each point. In some way having this folder make you think twice to connect a component to the store or call an endpoint, etc.

> Tip: Having unidentified components doing business logic increase project complexity, performance and reduce reusability. 

### Libs Folder

As you notice, I have a *libs* folder, here goes any functionality that is not related to react, but is usefull to shared functionalities between component or isolated a complex solutions inside a javascript module. There are diferent types of libs:

* *Business Logic*, for experience if you can write your business logic in pure javascript do it, after you have your feature in pure javascript you only need to create a wrapper for your current framework. This could be called as some kind of separations of concerns.
* *Helpers Functions*, are set of functions that solves a particular problem, for examples *hocs*, *events handlers*, etc.

### Redux (Ducks modules)

If you haven't read it about **ducks*, I highly recommend you to check the repo: [https://github.com/erikras/ducks-modular-redux], I use a modified version of ducks modules, it looks like this:



```javascript
/// Exported object of a redux module
export default reducer; // Reducer
export {
	name, // Expected name to be registered in the store
  actions, // Object with actions/actions creators
  selectors, // Object with selectors
}
```

You can see right away the value of this structur, you are exporting all what you need to update or retrieve information from redux state and for setup module in your applciation, you can see the value in your tests:

```javascript
import reducer, { name, actions, selectors} from '../auth.redux';

function setup(initialState = {}) {
  const middlewares = [thunk];

  const enhancers = [applyMiddleware(...middlewares)];
  const store = createStore(
    combineReducers({ [name]: reducer }),
    initialState,
    compose(...enhancers),
  );

  return {
    store,
  };
}

test('should be loading if a login attempt was made', () => {
  const { store } = setup();

  store.dispatch(actions.logIn(username, password)));
  
  expect(selectors.loading(store.getState())).toBe(true);
})
```

You are able to setup your redux state very easy and check if the expected selectors change given an action dispatched only with one import. Also, if you notice I dont do **unit test** for redux, after a lot test over my actions creators and redux, it was obvious that we are not generating value, but an **integration test** show exactly what are you wating from your actions.



## Shared Components/Libs