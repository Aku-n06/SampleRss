# Sample Rss Reader 
### General

  This is a sample code of an rss reader, with offline usage, that retrieve and show the
  feed from this url:
  http://newsrss.bbc.co.uk/rss/sportonline_world_edition/front_page/rss.xml
  
  The main design pattern of this application is the MVC, there are also a
  façade class (RSSAPI) and a singleton class (RSSDownloader), just to make
  an example.
  the RSSAPI send messages to the tableview using pushNotification; the
  RSSAPI's subclasses send a message to the parent class using delegation.

  For more detailed description of each class please read the comments on the
  header files.

  Thanks for your time.
  Best regards,
  Alberto
