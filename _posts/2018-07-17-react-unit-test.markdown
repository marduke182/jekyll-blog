---
layout: post
title: My Approach to do Unit Test in React
head_title: My Approach to do Unit Test in React [Opinionated]
date: 2018-07-17T10:00:00+01:00
last_modified_at: 2018-07-17T10:40:10+01:00
preview_image: react-unit-testing.jpg
keywords: jest, enzyme, react, test, unit
summary: Start to do tests is not easy, but if you are trying to do TDD and improving your code quality or velocity is a must. Doing test doesn't make you a faster developer but helps you a lot to maintain the code and you will have the confidence to do refactor and new features very fast. 
---

{% asset react-unit-testing.jpg class="center-image post-main-image" alt="React Unit Testing" !width !height %}

Start to do tests is not easy, but if you are trying to do TDD and improving your code quality or velocity is a must. Doing test doesn't make you a faster developer but helps you a lot to maintain the code and you will have the confidence to do refactor and new features very fast.

Write tests in new technology has his challenges, however, there is a lot of best practice to make easy to do on react, lets me explain it.

## Jest is your best friend

If you have been developed in javascript, you would notice **jest** is here, and it will stay for a few years. The time of karma, jasmine, chai, mocha has passed, they are good technologies yet but jest has made writing test very easy.

I remember an interview where I spent all the hour trying to configure karma :(, now you install jest and you are ready to go. Remember, you can rewrite your test to any assert library, so don't care about the technology

### Configuration

If you are using **create-react-app** you don't have to do any configuration, if you want to install some frameworks, you can do it at *src/setupFiles.js*.

If you are not using **create-react-app**, jest offers you a lot of options, my prefered is use  *package.json*, by default jest will look for any file with extension *.test.{js,jsx}* or *\_\_tests\_\_/\*.{js,jsx}*. You can check the documentation [here](https://jestjs.io/docs/en/configuration#testmatch-array-string).

## Use enzyme to improve developer experience

You can do tests without Enzyme, that's a fact, likewise, you can do a web application without React, Enzyme is for the test what React is for web development, a set of tools to improve your velocity and developer experience.

For example, this is a test with test utils:

```javascript
test('should create account', async () => {
  const createAccount = ReactTestUtils.renderIntoDocument(
    <CreateAccount onCreate={onCreate} />,
  );

  const [emailNode] = ReactTestUtils.findAllInRenderedTree(
    createAccount,
    el => el.name === 'email',
  );
  const [passwordNode] = ReactTestUtils.findAllInRenderedTree(
    createAccount,
    el => el.name === 'password',
  );
  const [buttonNode] = ReactTestUtils.findAllInRenderedTree(
    createAccount,
    el => el.type === 'submit',
  );

  emailNode.value = johnDoeEmail;
  ReactTestUtils.Simulate.change(emailNode);

  passwordNode.value = oneToThreePassword;
  ReactTestUtils.Simulate.change(emailNode);

  ReactTestUtils.Simulate.click(buttonNode);

  expect(onCreate).toHaveBeenCalledWith({
    email: johnDoeEmail,
    password: oneToThreePassword,
  });
});
```

And can be rewritten to this using enzyme:

```javascript
test('should create an account with enzyme', async () => {
  const createAccount = shallow(<CreateAccount onCreate={onCreate} />);

  const email = createAccount.find('input[name="email"]');
  const password = createAccount.find('input[name="password"]');

  email.instance().value = johnDoeEmail;
  email.simulate('change', email);

  password.instance().value = oneToThreePassword;
  password.simulate('change', password);

  createAccount.find('button').simulate('click');

  expect(onCreate).toHaveBeenCalledWith({
    email: johnDoeEmail,
    password: oneToThreePassword,
  });
});

```
You can look how the test is readable and focused on what you are asserting, you have a set of utils to assert, manipulate and traverse your React components. 

> Tip: Try to write your test the most readable possible. If you can't understand what is been tested, you need to rewrite your test.

To configure enzyme check his [homepage](https://github.com/airbnb/enzyme), also check [enzyme-matchers](https://github.com/FormidableLabs/enzyme-matchers) to have a set of helpers to do assertions to enzyme wrappers.

## Use shallow rendering

If you look at the last example, you will look I'm using **shallow(...)**, this helps us to test the component as a unit and prevent your tests been affected from child components behavior.

> Tip: Always test a unit of the component everything else that is not related to the assertion must be mocked, stub, etc.

There are few exceptions, for example:

* Testing a connected component to redux store
* A component wrapped with a **High Order Component**
* Any integration tests.

So in conclusion, use shallow for **unit testing** and mount for the **integration test**.

## Writing your tests

>  TLDR; Start writing your assertion, continue with the acts and finally arrange your tests.

Let's start writing the test, the first part is easy to write, the name, keep in mind the name should express your assertion very clear, for example:

```javascript
test('should create an account after add email, password and click continue', () => {})
```

### Assert

Now that you know the purpose of the test, so let's start writing the assertion.

```javascript
test('should create an account after add email, password and click continuar', () => {
  // 1. assert
  expect(onCreate)...
})
```

> Tip: Write only one assertion for the test, this will help you to know what is failing or asserting.

In React the assertion could be summarized in three things:

- Child component is been rendered.
- The function passed to components was called.
- Child component has a property.

### Acts

So now what are the actions that make the assertion valid? This is called **acts**,

```javascript
test('should create an account after add email, password and click continuar', () => {
  // 2. acts
  email.simulate('change', ...);
  password.simulate('change', ...);
  button.simulate('click', ...);
  
  // 1. assert
  expect(onCreate)...
})
```

React behaviors are specifics and can only trigger with few actions,

- Setting a specific prop, for example, should show loading if property loading is passed.
- Simulating an event from a user, like a click, change, blur, etc.
- Calling a function passed to the child component.

### Arrange

And finally, what does it mean email, password, and button? we need to **arrange** our test to have prepared all the required components, functions, etc. 

```javascript
test('should create an account after add email, password and click continuar', () => {
  // 3. arrange
  const { email, password, button } = setup();
  
  // 2. acts
  email.simulate('change', ...);
  password.simulate('change', ...);
  button.simulate('click', ...);
  
  // 1. assert
  expect(onCreate)...
})
```

We can implement this thing in many ways, but the one that helps me more, It was a **setup function**, the idea behind setup function is put in one place all the common task, like shallow/mount the components, how to find components, etc. This makes explicit the configuration and reduces the test from no related tasks.

Remember, the order is very important when you write your test (assert, act, arrange), it gives you perspective and focuses on what are you testing.

## Altogether

Let's rewrite our first example following this new concepts:

```javascript
function setup(props = {}) {
  const wrapper = shallow(<CreateAccount {...props} />);
    
  const createAccount = {
    wrapper,
    get email() { return wrapper.find('input[name="email"]')},
    get password() { return wrapper.find('input[name="password"]')},
    get button() { return wrapper.find('input[name="password"]')},
    
    typeEmail(value) {
      const email = createAccount.email;
      email.value = email;
      email.simulate('change', email)
    },
    typePassword(value) {
      const password = createAccount.password;
      password.value = value;
      password.simulate('change', password)
    }
  };
    
  return createAccount;
}

test('should create an account after add email, password and click continuar', async () => {
  const onCreate = jest.fn();
  const createAccount = setup({ onCreate });

  createAccount.typeEmail(johnDoeEmail);
  createAccount.typePassword(oneToThreePassword);
  createAccount.button.simulate('click');

  expect(onCreate).toHaveBeenCalledWith({
    email: johnDoeEmail,
    password: oneToThreePassword,
  });
});
```

You can look at how the different parts work together to create the final test.

## Resources

[Enzyme](https://github.com/airbnb/enzyme)

[Enzyme Matchers](https://github.com/FormidableLabs/enzyme-matchers)

[Jest](https://jestjs.io/)
