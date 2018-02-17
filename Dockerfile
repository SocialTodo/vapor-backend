FROM swift
ADD . ./
WORKDIR .
RUN swift build --configuration release
EXPOSE 8080
ENTRYPOINT [".build/release/Run"]
