<nav class="navbar bg-white px-4 shadow-sm">
    <div class="container-fluid justify-content-between">
        <input type="text" class="form-control w-50" placeholder="Search">

        <div class="d-flex align-items-center gap-3">
            <button class="btn btn-outline-secondary"><i class="bi bi-chat-left"></i></button>
            <button class="btn btn-outline-secondary"><i class="bi bi-bell"></i></button>
            {{-- <div class="d-flex align-items-center">
                <img src="https://via.placeholder.com/30" class="rounded-circle me-2" alt="foto">
                <span>Hi, Akbar</span>
            </div> --}}
            <div class="d-flex align-items-center">
                @if (auth()->check())
                <img src="{{ auth()->user()->photo_path ? asset('storage/' . auth()->user()->photo_path) : 'https://via.placeholder.com/30' }}"
                    class="rounded-circle me-2" alt="foto" width="30" height="30">
                <span>Hi, {{ auth()->user()->name }}</span>
                @else
                <img src="https://via.placeholder.com/30" class="rounded-circle me-2" alt="foto" width="30" height="30">
                <span>Hi, Guest</span>
                @endif
            </div>



        </div>
    </div>
</nav>
