# doi-ckan
This is the Department of the Interior's Open Data Portal powered by CKAN.


### Requirements

- [GNU Make](https://www.gnu.org/software/make/)
- [docker-compose](https://docs.docker.com/compose/)

### Development
If you want a basic system stood up:

1. run `make build`
1. run `make up`
1. point your browser to `localhost:5000`
1. To create an admin user, run `make test-user` (creates username: `test-user` and pwd: `test-user-password`)
1. To stop your containers and volumes run `make clean`

If you want a fully debuggable instance:

1. run `make build-dev`
1. Edit docker-compose.yml file, 
  - swap `image: doi-ckan:latest` for `image: doi-ckan:dev` on both ckan-web and ckan-worker
  - swap `ckan-web` command (see comments in file)
1. run `make up`
1. point your browser to `localhost:5000`
1. To create an admin user, run `make test-user` (creates username: `test-user` and pwd: `test-user-password`)
1. To stop your containers and volumes run `make clean`

#### Debug
If you want to be able to use pdb to debug the code, after running build and up run:

`docker-compose stop ckan-web && docker-compose run --service-ports ckan-web`

If you need to run a one-off ckan command (like rebuild search-index), use the following syntax:

`docker-compose exec ckan-worker bash -c 'paster --plugin=ckan search-index rebuild -c $CKAN_INI'`

### Release

To build a production ready version of the application, you will want to clean and rebuild:
`clean build-prod up-prod`. This will clean and rebuild the ckan image
for production, ignoring any cache.

Pushing to aws is now automated through github actions. It will build, run tests, and deploy to aws upon a push to the `production` branch.

If you need to manually push your image, follow the steps below.

Then, you can push this image to AWS for deployment by following the following steps. For many commands, you'll need the ecr-uri which you can find by running `aws ecr describe-repositories` and referencing the `repositoryUri` field.

Authenticate your AWS cli with docker:
`aws ecr get-login-password --region us-east-1| docker login --username AWS --password-stdin <ecr-uri>`

Then the steps are to 1) tag your image & 2) push to aws

Tag:
You'll want to run `docker images` to list all images on your current system. As of the first iteration, the repo is `doi-ckan_ckan-web` and the tag is `latest`. That yields the first part of the command.

The second part is what we want the repo:tag name to be on aws. In this case it's repo: `doi-ckan` and tag: `ckan`

In the first iteration, the tag command is:
`docker tag doi-ckan_ckan-web:latest <ecr-repo-uri>:ckan`

Push:
Now push your image with this command:
`docker push <ecr-repo-uri>/doi-ckan:ckan`

### Updating Dependencies
TODO: Fix this
The application uses the [requirements.txt file](./requirements/requirements.txt) for it dependency management. This is updated via the [requirements.in.txt file](./requirements/requirements.in.txt). To update the dependencies you need to run:

`make requirements build up`

This will update the requirements.txt file, build, and bring it up.
You should be able to see the application if you point your browser to localhost:5000.
Since integration tests are not implemented, manual verification of key usage 
(harvests, dataset pages, api, etc) should be done before pushing.
_TODO: Change this to `make requirements test`_

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

### How to Run Local Tests

1. Bring your app service up with `make clean build up`
1. Verify that the app comes up by hitting `http://localhost:5000` from your browser
1. Bring the FGDC2ISO service up (see steps above)
1. Create a user with `make test-user`. Verify that you have an `api.key` file at the root of this directory.
1. Import all harvest sources from production to your local instance and start them with `make seed-harvests` (this will take awhile)
1. Evaluate your local harvest sources compared with prod `make check-harvests`


### Useful Sites

- [okfn-docker-ckan](https://github.com/okfn/docker-ckan)
- [ckan documentation for installing with docker-compose](https://docs.ckan.org/en/2.8/maintaining/installing/install-from-docker-compose.html)