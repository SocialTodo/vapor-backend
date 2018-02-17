FROM swift
ADD . ./
WORKDIR .
RUN chmod +x ./generate_keys.sh ./generate_keys.sh
RUN swift build --configuration release
EXPOSE 8080
ENTRYPOINT [".build/release/Run"]
