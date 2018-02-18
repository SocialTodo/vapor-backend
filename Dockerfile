FROM swift
ADD . ./
WORKDIR .
RUN apt-get -qq update
RUN apt-get -qq -y install libpq-dev
RUN chmod +x ./generate_keys.sh ./generate_keys.sh
RUN swift build --configuration release
EXPOSE 8080
ENTRYPOINT [".build/release/Run"]
