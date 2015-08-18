read the pods for more documentation.

* lib/Perlude.pod
* lib/Perlude/Tutorial.pod

Current version is broken with perl < 5.16 because

* `&CORE::open` is not valid down there... i have to investigate
 or just *remove* `lines` from the perlude core (it is a very wrong place)
* yada (`...`) was introduced in perl 5.14 AFAIK
* investigate possible bug in range with 1 argument
* missing tests for oterate
