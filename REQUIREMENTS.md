Views
-----
Keyboard shortcuts
Time by when task must be done
Time when task was actually marked as done
Help in a popover with HTML
Hook up Backend. Use $http on the client, Dancer for API endpoints


MongoDB
-------
TodoCollection
Todo {
  uid NUMERIC,
  description STRING,
  deadline_unix NUMERIC,
  status BOOL
}

Redis
-----
Hash
  key: u:{uid}
  value: SET [
    {
      uid: ...,
      description: ...,
      deadline_unix: ...,
      status: ...
    }
  ]
