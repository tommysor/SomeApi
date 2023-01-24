using Server2.Todo;

namespace Server2;

/*
{
	"data": {
		"name": "SomeThing"
	},
	"datacontenttype": "application/json; charset=utf-8",
	"id": "ce653e28-7caa-49b0-94cd-d45c349d8c7d",
	"pubsubname": "servicebus-pub-sub",
	"source": "server11",
	"specversion": "1.0",
	"time": "2023-01-24T19:15:37Z",
	"topic": "send-update-request",
	"traceid": "00-892aa83f0ed9ea4b116ad4e6aee6d20d-376194344c9b75e0-01",
	"traceparent": "00-892aa83f0ed9ea4b116ad4e6aee6d20d-376194344c9b75e0-01",
	"tracestate": "",
	"type": "com.dapr.event.sent"
}
*/

public sealed class AcceptForUpdateDto
{
    public TodoCreateDto Data { get; set; } = default!;
    public Guid Id { get; set; }
    public string Datacontenttype { get; set; } = default!;
    public string Pubsubname { get; set; } = default!;
    public string Source { get; set; } = default!;
    public string Traceid { get; set; } = default!;
    public string Traceparent { get; set; } = default!;
}
