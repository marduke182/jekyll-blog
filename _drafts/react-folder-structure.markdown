---
layout: post
title: My final react folder structure
head_title: My final react folder structure [Opinionated]
preview_image: react-folder-structure.jpg
keywords: react, components, containers, folders
summary: 
---

Create React App solved the issue of project startup and Javascript fatigue, but there is not a common pattern for folder structure, I've been used different ways from projects to projects (sometimes in the same project, yes, It was a chaos).

## Folder by feature, not by type.

A good approach when you start with redux, is group all *actions*, *const*, *selectors* and *reducer* in the same business domain, or logic state, for example puttin all related to *authentication* together.

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

The same problem happens with react,  we have to types of elements in our applications **components** and **containers**, but the first approach we do, is putting all diferent logic elements into the same folders, increasing the scalability of the project, for example:

```bash
src
|_components
  |_Fields
    |_Input.jsx
    |_...
  |_LoginForm.jsx
  |_CreateAccountForm.jsx
  |_ProductList.jsx
  |_...
|_containers
  |_LoginPage.jsx
  |_CreateAccountPage.jsx
  |_ProductsPage.jsx
  |_...
```



We can look that the *LoginForm* is together with *ProductList*, now we can imagine what will happens if the project increase to having a complete eCommerce. I solve this issue using what I called **Feature Module**, the idea is to encapsulate everything related to logical implementation together. 

## Feature Module

A feature module try to encapsulate all logic related to his own folder, this bring a lot of benefits that I will explain later. It looks like this:

```bash
src
|_auth
  |_components
  |_containers
  |_libs
  |_auth.redux.js
```

Each module could contains this folders:

### Components

We can define a component if has the next properties:

* Behaves in an isolate way, don't have any interaction with external world (connect to apis, etc)

* Internal state is allowed, but not required (the last one are called presentational component)

* **Never** is connected to a redux store, mobx, etc. The comunication with components should be only by props.


### Containers

Containers are components but that are allowed to connect to external apis, redux sture, mobx. **Why is this separation?**, we want to identify all critical components, and the most critical are the ones to do impure actions.

> Tip: Having unidentified components doing business logic increase project complexity, performance and reduce reusability. 

### Libs Folder

Here goes any functionality that is not related to react, but is usefull to shared functionalities between component or isolated a complex solutions inside a javascript module. There are diferent types of libs:

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

You can see right away the value of this structure, you are exporting all what you need to update or retrieve information from redux state and for setup module in your application, you can see the value in your tests:

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

We always 