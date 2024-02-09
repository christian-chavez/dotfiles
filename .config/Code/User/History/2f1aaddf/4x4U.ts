import author from "./author";
import menu from "./menu";

export default {
  site: {
    siteMetadata: {
      url: "some url ",
      title: "Blog by John Doe",
      subtitle:
        "Pellentesque odio nisi, euismod in, pharetra a, ultricies in, diam. Sed arcu.",
      copyright: "All rights reserved.",
      postsPerPage: 4,
      author,
      menu,
    },
  },
};
