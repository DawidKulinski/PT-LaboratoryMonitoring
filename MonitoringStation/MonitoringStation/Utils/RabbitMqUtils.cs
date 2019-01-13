using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Mail;
using System.Runtime.InteropServices;
using System.Runtime.Remoting.Channels;
using System.Text;
using System.Threading.Tasks;
using System.Configuration;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using RabbitMQ.Client.Framing.Impl;


namespace MonitoringStation.Utils
{
    public class RabbitMqUtils
    {
        private static readonly string _certPath;
        private static readonly string _certPassword;
        private static readonly string _queueName;
        private static readonly string _userName;

        static RabbitMqUtils()
        {
            _certPath = ConfigurationManager.AppSettings["CertPath"];

            _certPassword = ConfigurationManager.AppSettings["CertPassword"];

            _queueName = ConfigurationManager.AppSettings["QueueName"];

            _userName = ConfigurationManager.AppSettings["UserName"];
        }
        


        private static void PrepareConnection(Action<IModel> sendAction)
        {
            var factory = new ConnectionFactory()
            {
                HostName = "127.0.0.1",
                AuthMechanisms = new AuthMechanismFactory[] {new ExternalMechanismFactory()},
                UserName = "client1",               
                Ssl = new SslOption
                {
                    ServerName = "admin",
                    CertPath = _certPath,                    
                    CertPassphrase = _certPassword,
                    Enabled = true
                }
            };

            //factory.Ssl.AcceptablePolicyErrors = System.Net.Security.SslPolicyErrors.RemoteCertificateNameMismatch;

            using (var connection = factory.CreateConnection())
            using (var channel = connection.CreateModel())
            {
                sendAction(channel);
            }
        }

        public static void Send(byte[] message, string type)
        {
            Console.WriteLine(Encoding.ASCII.GetString(message));

            PrepareConnection(model =>
            {
                IBasicProperties props = model.CreateBasicProperties();

                props.UserId = "client1";
                props.Type = type;

                model.QueueDeclare(queue: _queueName,
                    durable: false,
                    exclusive: false,
                    autoDelete: false,
                    arguments: null);

                model.BasicPublish(exchange:"",
                    routingKey:_queueName,
                    basicProperties:props,
                    body:message);
            });
        }

        public static byte[] Receive()
        {
            byte[] message = new byte [1];
            PrepareConnection(model =>
            {
                model.QueueDeclare(queue: _queueName,
                    durable: false,
                    exclusive: false,
                    autoDelete: false,
                    arguments: null);

                var consumer = new EventingBasicConsumer(model);

                consumer.Received += (model1, ea) =>
                {
                    message = ea.Body;
                };

                model.BasicConsume(queue: "hello",
                    autoAck: true,
                    consumer: consumer);
            });

            return message;
        }


    }
}
