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

### Updating Dependencies
The application uses the [requirements-freeze.txt file](./ckan/requirements-freeze.txt) for it dependency management. This is updated via the [requirements.txt file](./ckan/requirements.txt). To update the dependencies you need to run:

`make clean build requirements up`

This will start a fresh build, update the requirements-freeze.txt file, and bring it up.
You should be able to see the application if you point your browser to localhost:5000.
Since integration tests are not implemented, manual verification of key usage 
(harvests, dataset pages, api, etc) should be done before pushing.

### FGDC2ISO

In order to harvest an CSDGM/FGDC metadata source, you will need to have a running FGDC2ISO service available.
This is set in the .env file under `CKANEXT__GEODATAGOV__FGDC2ISO__SERVICE`.
If you would like to have a system running on your local system, follow the 
[setup instructions](https://github.com/GSA/catalog-fgdc2iso). 
You will need to make the application available on the docker-compose network built here, 
so add the following lines to the fgdc2iso docker-compose file (after doi-ckan is built and running):

```
networks:
  default:
    external:
      name: doi-ckan_default
```
Then spin up catalog-fgdc2iso using `docker-compose up`, and you should have a working service
to transform CSDGM metadata into ISO.

#### Current issues/workarounds

Currently, the FGDC2ISO repo does not build properly with a saxon-license file.
A workaround was implemented, where we added the DOI file as `saxon-license-doi.lic`,
and then changed line 9 of the docker-compose file from `./saxon-license.lic:/etc/saxon-license.lic`
to be `./saxon-license-doi.lic:/etc/saxon-license.lic`

### Helpful Commands

- Start a command-prompt for the application: `make hop-in`
- To completely clean your docker instances run  `make clean` then `make prune`


### Useful Sites

- [okfn-docker-ckan](https://github.com/okfn/docker-ckan)
- [ckan documentation for installing with docker-compose](https://docs.ckan.org/en/2.8/maintaining/installing/install-from-docker-compose.html)