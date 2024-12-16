import { createLazyFileRoute } from '@tanstack/react-router'
import { useAuth } from '../hooks/use_auth'
import { Button } from '@/components/ui/button'

export const Route = createLazyFileRoute('/')({
  component: Index,
})

function Index() {
  const {logout} = useAuth()
  return (
    <div ><h1 className='text-sky-700'>Hello from Home!</h1>
    <Button onClick={() => {
      logout()
    }}>Logout</Button>
</div>
  )
}