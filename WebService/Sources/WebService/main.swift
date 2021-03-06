import Foundation
import Apodini
import ApodiniObserve
import ApodiniObserveOpenTelemetry
import ApodiniObservePrometheus
import ApodiniOpenAPI
import ApodiniREST
import ApodiniDatabase
import ApodiniAuthorizationJWT
import Shared
import ArgumentParser
import FluentPostgresDriver
import LoggingELK


struct FA2021WebService: WebService {
    @Option(help: "The port the web service should bind to")
    var port: Int = 8080
    
    @Environment(\.eventLoopGroup)
    var eventLoopGroup
    
    @Environment(\.logger)
    var logger
    
    var configuration: Configuration {
        // Exposed interfaces, in this case a RESTful API and an OpenAPI documentation generated with it
        REST(encoder: jsonEncoder, decoder: jsonDecoder) {
            OpenAPI(swaggerUiEndpoint: "/swagger")
        }
        
        // Defines on which hostname and port the webservice should be bound to, configurable via CLI-arguments, else defaults
        HTTPConfiguration(bindAddress: .interface("0.0.0.0", port: port))
        
        // Setup of ApodiniLogger with a LogstashLogHandler backend
        LoggerConfiguration(
            logHandlers: LogstashLogHandler.init,
            logLevel: .info
        ) {
            LogstashLogHandler.setup(
                hostname: ProcessInfo.processInfo.environment["LOGSTASH_HOST"] ?? "0.0.0.0",
                port: Int(ProcessInfo.processInfo.environment["LOGSTASH_PORT"] ?? "31311") ?? 31311,
                useHTTPS: false,
                eventLoopGroup: eventLoopGroup,
                backgroundActivityLogger: logger,
                uploadInterval: TimeAmount.seconds(15),
                logStorageSize: 128_000,
                maximumTotalLogStorageSize: 512_000
            )
        }
        
        // Setup of ApodiniMetrics with a Prometheus backend
        MetricsConfiguration(
            handlerConfiguration: MetricPullHandlerConfiguration.defaultPrometheusWithConfig(
                endpoint: "/metrics",
                timerImplementation: .summary(),
                defaultRecorderBuckets: .defaultBuckets
            ),
            systemMetricsConfiguration: .default
        )

        // Setup of Tracing with an OpenTelemetry backend
        TracingConfiguration(
            .defaultOpenTelemetry(serviceName: "FA2021")
        )
        
        // Setup of ApodiniAuthorization
        JWTSigner(.hs256(key: "secret"))
        
        // Setup of database and add migrations to create the respective tables
        DatabaseConfiguration(
            .postgres(
                hostname: ProcessInfo.processInfo.environment["POSTGRES_HOST"] ?? "0.0.0.0",
                port: Int(ProcessInfo.processInfo.environment["POSTGRES_PORT"] ?? "5432") ?? 5432,
                username: ProcessInfo.processInfo.environment["POSTGRES_USER"] ?? "ScienceLab",
                password: ProcessInfo.processInfo.environment["POSTGRES_PASSWORD"] ?? "FA2021",
                database: ProcessInfo.processInfo.environment["POSTGRES_DB"] ?? "science_lab"
            ),
            as: .psql
        )
            .addMigrations(MeasurementMigration())
            .addMigrations(SensorTypeMigration())
            .addMigrations(SensorMigration())
            .addMigrations(MeasurementDataMigration())
            .addMigrations(UserMigration())
            .addMigrations(TokenMigration())
    }

    var content: some Component {
        MeasurementComponent()
            .record(.all)
            .trace()
        SensorTypeComponent()
            .record(.all)
            .trace()
        AuthComponent()
            .record(.all)
            .trace()
        DummyComponent()
            .record(.all)
            .trace()
    }
}


FA2021WebService.main()
