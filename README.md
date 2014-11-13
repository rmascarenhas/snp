# snp - easy snippets for everyone

`snp` is a tool to allow easy snippet creation, in an automated and reusable manner.
How many times did you create that small HTML document to test out if something worked
quite the way you thought it did? `snp`'s goal is to free the user from the creation
of all boilerplate involved in the creation of such snippets, allowing the programmer
to focus immediately on the feature that she wants to test.

### Motivation

It is often in many situations that we wonder how something works in a language or
library. One of the best ways to find out the answer in such scenarios is to create
a minimum piece of code that can test the specific case we have in mind. However,
creating such files may involve some overhead and the creation of boilerplate code
to allow the testing. This can cause people to give up creating the snippet and instead
just look up on the Internet, which can take more time and you likely will not learn
as much. The goal of this project is, therefore, reduce the cost of testing and
learning on your own.

### Example

`snp` is especially useful for quick tests that you want to perform in environments
in which a significant amount of boilerplate is involved. Suppose you frequently
test the expected effect of `jQuery` functions. You could create a snippet such as

~~~erb
<%# file: ~/.snp/jquery_test.js.erb %>
<html>
  <head><title><%= title %></title></head>

  <body>

    <script src="http://code.jquery.com/jquery-<%= jquery_version %>.min.js"></script>

    <script>
      (function() {
        // code goes here
      })();
    </script>
  </body>
</html>
~~~

With that file set up once, whenever you want to perform a test of something related to
`jQuery` all you have to do is type:

~~~console
$ snp --title callbacks --jquery-version 2.1.1 jquery_test.js
~~~

Variable substitutions happen as you expect them to, and your favorite editor is fired up
with the snippet content, waiting for you to actually test what you wanted in the first place.

### Rules of the game

* Snippet templates are by default placed under the `~/.snp` directory. You can
override that by defining the `SNP_PATH` environment variable, which accepts a
list of directories in pretty much the same way that the shell's `PATH` does.

* All snippet templates are ERB files and must have a name with the according
`.erb` extension.

* You do not have fill in every piece of dynamic content in the command line when
creating a new template from a template. They can have defaults and you can define
them by placing a yaml file with the same name as the template with the default
contents of each dynamic piece of content in the template. Note that arguments
passed to the command line override those definitions.

Example: suppose you have the following snippet named `introduction.txt.erb`:

~~~erb
<%= greeting %>, my name is <%= name %>, and I'm from <%= country %>.
~~~

You can then create a `introduction.txt.yml` file to define the default values for
the dynamic variables in the snippet above:

~~~yaml
greeting: "Hello"
name: "Renato"
country: "Brazil"
~~~

Now you can create snippets from that template using the default values using just:

~~~console
$ snp introduction.txt
# => content is "Hello, my name is Renato, and I'm from Brazil."
~~~

You can override specific values when creating a new snippet as well:

~~~console
$ snp --name David --country UK
# => content is "Hello, my anme is David, and I'm from UK.
~~~

### Contributions/Bugs

Email me, or create an issue/pull request on the GitHub repository.

### License

MIT. See `MIT-LICENSE` file for details.
