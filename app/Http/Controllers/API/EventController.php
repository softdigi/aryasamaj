<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Event;
use Illuminate\Http\Request;

class EventController extends Controller
{
    /**
     * GET /api/events
     * ?filter=upcoming|past|all  ?page=1
     */
    public function index(Request $request)
    {
        $q = Event::published();

        $filter = $request->get('filter', 'all');
        if ($filter === 'upcoming') {
            $q->where('status', 'upcoming')
              ->where('event_date', '>=', now())
              ->orderBy('event_date');
        } elseif ($filter === 'past') {
            $q->where(fn($b) => $b->where('status', 'past')->orWhere('event_date', '<', now()))
              ->orderByDesc('event_date');
        } else {
            $q->orderByDesc('event_date');
        }

        $events = $q->paginate(20);

        return response()->json([
            'status'     => 'success',
            'data'       => $events->map(fn($e) => $this->format($e)),
            'pagination' => [
                'current_page' => $events->currentPage(),
                'last_page'    => $events->lastPage(),
                'total'        => $events->total(),
            ],
        ]);
    }

    /**
     * GET /api/events/{id}
     */
    public function show(int $id)
    {
        $event = Event::published()->findOrFail($id);
        return response()->json(['status' => 'success', 'data' => $this->format($event)]);
    }

    private function format(Event $e): array
    {
        return [
            'id'          => $e->id,
            'title'       => $e->title,
            'description' => $e->description,
            'event_date'  => $e->event_date?->toIso8601String(),
            'location'    => $e->location,
            'image_url'   => $e->image_url,
            'status'      => $e->status,
        ];
    }
}
