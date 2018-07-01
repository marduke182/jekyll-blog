---
layout: post
title: Writing proper frontend acceptance tests
head_title: Frontend Acceptance Tests [Introduction]
date: 2018-02-23T10:00:00+01:00
last_modified_at: 2018-02-01T22:10:10+01:00
preview_image: signs.jpg
keywords: e2e, frontend, puppeteer, jest, server stub, tests, acceptance, tdd
summary: Writing acceptance test in frontend are not easy, you need to test behavior but E2E test are to complicate to implement and not reliable, I'll show my current approach.
---

{% asset jekyll-seo-tutorial.jpg class="center-image post-main-image" alt="Jekyll SEO tutorial represented by tools" !width !height %}

The first thing you heard about TDD is this:

1. Write your acceptance test, should not pass.
2. Write your unit test, should not pass.
3. Write your code who make unit test written in the second step passes.
4. Refactor your code.
5. Repeat step 2,3,4 until acceptance test goes green.

When I saw this I said, "Oh TDD is so easy", but I started writing the acceptance and I have no idea how to start and normal, if you work on a backend API, could be easy to do, just call the endpoint a wait for an expected response, for a library check if top-level API es working.

So how I do it in a frontend application? what is our top-level API? The answer: the browser (HTML, CSS, javascript altogether),  User uses our application by clicking, typing, navigating, etc. so we can do our acceptance testing interacting directly with the browser and wait for the expected behavior happen.

All this sound familiar, Have you heard about selenium? E2E tests? Is the same but with server stubbing and without old selenium API.

### How to write E2E tests without a backend API

We need few things:

* A test environment to run the tests and allow us to stub the requests
* A server stubbing library to handle the requests
* **Recommended** A page objects library

For the first one, we are gonna use **Jest** and **Puppeteer**. I'll write another article about how to integrate these technologies together. There are few articles on the internet about how to do it. The important part here is:

The piece of server stubbing:

For the second one I wrote my own piece of code, It's very simple and gives you a simple API to write, use and asserts contracts. You can see more about the implementation here, or wait for my other post.

Finally, I created a set of helpers to store all page behavior in the same place, this is a well-known Page Object pattern.

This is the final resulting code, you can find all boilerplate here:


## Conclusion
* This helps you to replicate any complicated state of your application, without interacting with external services.
* You can run this tests in production without affecting your database, statistics, etc.
* Are fast and more reliable than normal E2E tests.
* Helps you to do a proper TDD working process.
* Not all is perfect, the Achilles heel here are the contracts, if you integrate this solution with contract testing like Pact, you can assure high-quality frontend product.