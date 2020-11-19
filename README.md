# doi-ckan
This is the Department of the Interior's Open Data Portal powered by CKAN.


### Requirements

- [GNU Make](https://www.gnu.org/software/make/)
- [docker-compose](https://docs.docker.com/compose/)

### Development

1. run `make build`
1. run `make up`
1. point your browser to `localhost:5000`
1. To create an admin user, run `make admin` and follow the prompts for email and password
1. To stop your containers and volumes run `make clean`

### Helpful Commands

- Start a command-prompt for the application: `make hop-in`
- To completely clean your docker instances run  `make clean` then `make prune`


### Useful Sites

- [okfn-docker-ckan](https://github.com/okfn/docker-ckan)
- [ckan documentation for installing with docker-compose](https://docs.ckan.org/en/2.8/maintaining/installing/install-from-docker-compose.html)