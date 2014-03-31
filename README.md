Todo
====

Setting Up for Development
--------------------------

Todo is a `Dancer` application. So, you need to have `perl` installed on your machine.
Perl `5.16.2` was used for development. So, it definitely works on that.

Required `perl` modules include:

 - `Dancer`
 - `MongoDB`
 - `LWP`

Once you have sorted out the dependencies, you can launch the server app by doing:

    perl app.pl

This will start the server application on port `3000`. Try `perl app.pl --help`
to find out the list of supported options. If you are familiar with `Dancer`, you'll
recognize that this is the same way as you'd launch any other `Dancer` app.

The app uses a local `MongoDB` server to persist its data. So, ensure that you have
`mongod` installed locally, then start the daemon:

    mongod --fork

Client dependencies are described in a `bower.json` file at `public/static/`.
Navigate to that directory and do:

    bower install

This will download all the required libraries.

Now, navigate to `http://localhost:3000` on your browser and you should see the
app running for you.
