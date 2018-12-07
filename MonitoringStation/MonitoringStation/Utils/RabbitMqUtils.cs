using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Mail;
using System.Runtime.InteropServices;
using System.Runtime.Remoting.Channels;
using System.Text;
using System.Threading.Tasks;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using RabbitMQ.Client.Framing.Impl;

namespace MonitoringStation.Utils
{
    public class RabbitMqUtils
    {
        private static void PrepareConnection(Action<IModel> sendAction)
        {
            var factory = new ConnectionFactory()
            {
                HostName = "localhost"
            };
            using (var connection = factory.CreateConnection())
            using (var channel = connection.CreateModel())
            {
                sendAction(channel);
            }
        }

        public static void Send(byte[] message)
        {
            PrepareConnection(model =>
            {
                model.QueueDeclare(queue: "Hello",
                    durable: false,
                    exclusive: false,
                    autoDelete: false,
                    arguments: null);

                model.BasicPublish(exchange:"",
                    routingKey:"hello",
                    basicProperties:null,
                    body:message);
            });
        }

        public static byte[] Receive()
        {
            byte[] message = new byte [1];
            PrepareConnection(model =>
            {
                model.QueueDeclare(queue: "hello",
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
