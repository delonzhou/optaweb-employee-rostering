# Copyright 2019 Red Hat, Inc. and/or its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This is a multi-staged Dockerfile that uses Maven builder image to build the whole project with Maven.
# In the second phase, the standalone Quarkus executable JAR is placed into an OpenJDK JRE image.
#
# Build an image:
# docker build -t optaweb/employee-rostering --ulimit nofile=98304:98304 .
#
# Run the image with default profile (using in-memory H2 database):
# docker run -p 8080:8080 --rm -it optaweb/employee-rostering
#
# Run the image with production profile (using PostgreSQL database):
# docker run -p 8080:8080 --rm -it -e QUARKUS_PROFILE=production optaweb/employee-rostering

FROM adoptopenjdk/maven-openjdk11:latest as builder
WORKDIR /usr/src/optaweb
COPY . .
RUN mvn -q clean install -DskipTests

FROM adoptopenjdk/openjdk11:ubi-minimal
RUN mkdir /opt/app
COPY --from=builder /usr/src/optaweb/optaweb-employee-rostering-standalone/target/quarkus-app /opt/app/optaweb-employee-rostering
CMD ["java", "-jar", "/opt/app/optaweb-employee-rostering/quarkus-run.jar"]
EXPOSE 8080
